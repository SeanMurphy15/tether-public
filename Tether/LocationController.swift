//
//  LocationController.swift
//  Tether
//
//  Created by Zach Steed on 1/5/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

let locationUpdatedKey = "locationUpdated"


class LocationController: NSObject, CLLocationManagerDelegate {

    static let sharedInstance = LocationController()
    
    enum promptStatus {
        case Continue
        case AuthorizeLocation
        case GoToSettings
    }

    var isInBackground: Bool = false
    var dateToKill: NSDate? = nil

    var locationManager = CLLocationManager()
    
    var lastHeading: CLLocationDirection? = nil

    override init() {
        super.init()
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = 1
        locationManager.delegate = self
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.activityType = .OtherNavigation
        locationManager.allowsBackgroundLocationUpdates = true

    }

    //MARK: - Location Delegate Methods
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        
        let location = locations.last!
        if let currentUser = UserController.sharedInstance.currentUser {
            currentUser.location = location
            NSNotificationCenter.defaultCenter().postNotificationName("userLocationChanged", object: self, userInfo: ["location":location])
        }

        if isInBackground {
            if let dateToKill = dateToKill {
                if NSDate().compare(dateToKill) == .OrderedDescending {
                    locationManager.stopUpdatingLocation()
                    FirebaseController.removeValueAtEndpoint(UserController.sharedInstance.currentUser.locationEndpoint, completion: { (success) -> Void in
                        if !success {
                            print("Location for current user not being removed")
                        }
                    })
                }
            } else {
                self.dateToKill = NSDate(timeIntervalSinceNow: 60*60*2)
            }
        }
    }
    
    func locationManagerShouldDisplayHeadingCalibration(manager: CLLocationManager) -> Bool {
        return true
    }

    // MARK: - Location permissions handling
    static func shouldPromptForLocationAuthorization(completion: (promptStatus: promptStatus) -> Void) {
        switch CLLocationManager.authorizationStatus() {
        case .AuthorizedAlways:
            completion(promptStatus: .Continue)
        case .AuthorizedWhenInUse, .Denied, .Restricted:
            completion(promptStatus: .GoToSettings)
        case .NotDetermined:
            completion(promptStatus: .AuthorizeLocation)
        }
    }
    
    static func authorizeLocationUse() {
        sharedInstance.locationManager.requestAlwaysAuthorization()
    }


    // Error handling if location isn't found

    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Errors: " + error.localizedDescription)
    }


    // Should update map when user moves
    func locationManager(manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        guard newHeading.headingAccuracy > 0 else {return}
        let lastHeading = self.lastHeading ?? 0
        let heading = (newHeading.trueHeading > 0) ? newHeading.trueHeading:newHeading.magneticHeading
        if abs(lastHeading - heading) < 10 {
            NSNotificationCenter.defaultCenter().postNotificationName("userHeadingChanged", object: self, userInfo: ["heading":heading])
        }
        self.lastHeading = heading
        NSNotificationCenter.defaultCenter().postNotificationName("userHeadingChanged", object: self)
    }



    func degreesToRadians(degrees: Double) -> Double {
        return degrees * M_PI / 180.0
    }

    func radiansToDegrees(radians: Double) -> Double {
        return radians * 180.0 / M_PI
    }

    func getHeadingBetweenTwoPoints(userLocation: CLLocation, target: CLLocation) -> Double {
        let lat1 = degreesToRadians(userLocation.coordinate.latitude)
        let lon1 = degreesToRadians(userLocation.coordinate.longitude)

        let lat2 = degreesToRadians(target.coordinate.latitude)
        let lon2 = degreesToRadians(target.coordinate.longitude)

        let distanceLon = lon2 - lon1

        let x = cos(lat2) * sin(distanceLon)
        let y = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(distanceLon)
        let radiansBearing = atan2(x,y)
//        return (2 * M_PI) - (radiansBearing) * (M_PI_2)
        return radiansToDegrees(radiansBearing) >= 0 ? radiansToDegrees(radiansBearing):radiansToDegrees(radiansBearing)+360
    }

    func findAddressOfLocation(location: CLLocation, completion: (approximateAddress: String?) -> Void) {

        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in

            var locationArray: [String] = []
            let location = placemarks![0] as CLPlacemark

            switch (placemarks?.count > 0) {

            case error != nil:
                print("There was a problem reversing geocode: \(error?.localizedDescription)")
                break;
            case location.name != nil:
                if let street = location.name
                {locationArray.append(street)}
                fallthrough;
            case location.locality != nil:
                if let city = location.locality
                {locationArray.append(city)}
                fallthrough;
            case location.administrativeArea != nil:
                if let state = location.administrativeArea
                {locationArray.append(state)}
                fallthrough;
            default:
                break;
            }

            let fullAddress = locationArray.joinWithSeparator(" ")

            completion(approximateAddress: fullAddress)
        })
        
    }
}









