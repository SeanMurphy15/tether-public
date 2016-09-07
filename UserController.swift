//
//  UserController.swift
//  Tether
//
//  Created by James Pacheco on 1/5/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation
import CoreLocation
import Firebase

class UserController {

    static let sharedInstance = UserController()
    var newTetherHandles: [String:FirebaseHandle] = [:]
    var requestsSent: [Friend] = [] {
        didSet {
            NSNotificationCenter.defaultCenter().postNotificationName("userArraysChanged", object: self)
            let newRequestSent = requestsSent.filter { (newRequest) -> Bool in
                !oldValue.contains({ (oldRequest) -> Bool in
                    return newRequest.number == oldRequest.number
                })
            }
            for friendToNotify in newRequestSent {
                ParseController.sendPushNotification(friendToNotify)
            }
        }
    }
    var requestsReceived: [Friend] = [] {
        didSet {
            if requestsReceived.count > 0 {
                LocalNotificationController.sharedInstance.localNotificationSettingAlert()
            }
            NSNotificationCenter.defaultCenter().postNotificationName("userArraysChanged", object: self)
            if requestsReceived.count > 0 {
                print("Request received")
            }
        }
    }
    var tethered: [Tether] = [] {
        didSet {
            NSNotificationCenter.defaultCenter().postNotificationName("friendLocationChanged", object: self)
            observeTethers(tethered)
            let deletedTethers = oldValue.filter { (oldTether) -> Bool in
                !tethered.contains({ (newTether) -> Bool in
                    return oldTether.identifier == newTether.identifier
                })
            }
            for tether in deletedTethers {
                if let handle = tether.handle {
                    FirebaseController.base.childByAppendingPath("locations/\(tether.friend.number)").removeObserverWithHandle(handle)
                }
            }
            let newTethers = tethered.filter { (newTether) -> Bool in
                !oldValue.contains({ (oldTether) -> Bool in
                    return newTether.identifier == oldTether.identifier
                })
            }
            for tether in newTethers {
                newTetherHandles[tether.friend.number] = FirebaseController.observeValueAtEndpoint("locations/\(tether.friend.number)", completion: { (key, value) -> Void in
                    if let value = value as? [String: Double],
                        lat = value["lat"],
                        lon = value["lon"] {
                            let location = CLLocation(latitude: lat, longitude: lon)
                            NSNotificationCenter.defaultCenter().postNotificationName("newTetherLocationReceived", object: self, userInfo: ["location": location, "friendNumber": tether.friend.number])
                    }
                })
            }

            NSNotificationCenter.defaultCenter().postNotificationName("userArraysChanged", object: self)
            if CLLocationManager.authorizationStatus() == .AuthorizedAlways {
                if tethered.count > 0 {
                    LocationController.sharedInstance.locationManager.startUpdatingLocation()
                } else {
                    LocationController.sharedInstance.locationManager.stopUpdatingLocation()
                    FirebaseController.removeValueAtEndpoint(currentUser.locationEndpoint, completion: { (success) -> Void in
                        if !success {
                            print("Location for current user not being removed")
                        }
                    })
                }
            } else {
                // TODO: - Present alert saying that app doesn't work without location permissions
            }
        }
    }
    var currentUser: User! {
        get {
            guard let number = NSUserDefaults.standardUserDefaults().valueForKey("currentUser") as? String else {return nil}
            return User(number: number)
        }
        
        set {
            if let newValue = newValue {

                NSUserDefaults.standardUserDefaults().setValue(newValue.number, forKey: "currentUser")
                NSUserDefaults.standardUserDefaults().synchronize()
                FirebaseController.anonymousLoginToFirebase { (success) -> Void in
                    if success {
                        FirebaseController.loadNecessaryItems()
                        ParseController.saveUsersDevice()
                        FirebaseController.setValueAtEndpoint("users/\(newValue.number)", value: true, completion: { (success) -> Void in
                            
                            
                            if !success {
                                print("Couldn't put user number into Firebase")
                            }
                        })
                    }
                }
            } else {
                NSUserDefaults.standardUserDefaults().removeObjectForKey("currentUser")
                NSUserDefaults.standardUserDefaults().synchronize()
            }
        }
    }
    
    var purchased: Bool {
        get {
            guard let purchase = NSUserDefaults.standardUserDefaults().valueForKey("premiumPurchase") as? Bool else {return false}
            return purchase
        }
        set {
            NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "premiumPurchase")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    func updateCurrentUserLocation(location: CLLocation) {
        currentUser.location = location
        FirebaseController.setValueAtEndpoint(currentUser.locationEndpoint, value: currentUser.locationJson) { (success) -> Void in
            guard success else {
                print("Could not update current user's location")
                return
            }
        }
    }
    
    func observeTethers(tethers: [Tether]) {
        for tether in tethered {
            let handle = FirebaseController.base.childByAppendingPath("locations/\(tether.friend.number)").observeEventType(.Value, withBlock: { (data) -> Void in
                if let value = data.value as? [String: Double],
                    lat = value["lat"],
                    lon = value["lon"] {
                        let location = CLLocation(latitude: lat, longitude: lon)
                        tether.friend.location = location
                        NSNotificationCenter.defaultCenter().postNotificationName("friendLocationChanged", object: self)

                }
            })
            tether.handle = handle
        }
    }
    
    func mockUser() -> User {
        let user1 = User(number: "+15712013866", location: CLLocation(latitude: 50, longitude: 70))
        
        return user1
    }
}