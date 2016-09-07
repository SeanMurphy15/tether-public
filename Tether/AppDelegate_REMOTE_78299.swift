//
//  AppDelegate.swift
//  Tether
//
//  Created by Michael Sacks on 1/4/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import UIKit
import Fabric
import DigitsKit
import CoreLocation
import Contacts


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
//        if let options = launchOptions {
//            if let notification = options[UIApplicationLaunchOptionsLocalNotificationKey] as? UILocalNotification {
//                if let userInfo = notification.userInfo {
//                    let message = userInfo["Message"] as! String
//                }
//            }
//        }
        application.applicationIconBadgeNumber = 0
        Fabric.with([Digits.self])
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        AppearanceController.setUpAppearance()


        // Override point for customization after application launch.
        if UserController.sharedInstance.currentUser != nil {
            if let _ = FirebaseController.base.authData?.uid {
                FirebaseController.loadNecessaryItems()
            } else {
                FirebaseController.anonymousLoginToFirebase({ (success) -> Void in
                    if success {
                        FirebaseController.loadNecessaryItems()
                    }
                })
            }
        }
        if CLLocationManager.authorizationStatus() == .AuthorizedAlways {
            LocationController.sharedInstance.locationManager.requestLocation()
        }
        return true
    }

    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        if let userInfo = notification.userInfo {
            if let message = userInfo["Message"] as? String {
                print("Local Notification Confirmed \(message)")
    //            application.applicationIconBadgeNumber = application.applicationIconBadgeNumber + 1
            }
        }
    }

    func applicationWillResignActive(application: UIApplication) {
    }

    func applicationDidEnterBackground(application: UIApplication) {
        LocationController.sharedInstance.locationManager.distanceFilter = 15
        LocationController.sharedInstance.locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        application.applicationIconBadgeNumber = 0
        for tether in UserController.sharedInstance.tethered {
            LocalNotificationController.sharedInstance.scheduleDeleteTetherNotifications(tether)
        }
        LocationController.sharedInstance.isInBackground = true
        LocationController.sharedInstance.locationManager.stopUpdatingHeading()
    }

    func killApp() {
        exit(0)

    }

    func applicationWillEnterForeground(application: UIApplication) {
        LocationController.sharedInstance.locationManager.distanceFilter = 5
        LocationController.sharedInstance.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
//        application.applicationIconBadgeNumber = 0
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        LocationController.sharedInstance.isInBackground = false
    }
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {

        if (identifier == "CANCEL_ACTION") {
            if let userInfo = notification.userInfo {
                if let number = userInfo["tether"] as? String {
                    if let tether = UserController.sharedInstance.tethered.filter({$0.friend.number == number}).first {
                        UIApplication.sharedApplication().cancelAllLocalNotifications()
                        TetherController.removeTether(tether, completion: { (success) -> Void in
                            print(success)
                        })
                    }
                }
            }
        } else if (identifier == "CONTINUE_ACTION") {
            if let userInfo = notification.userInfo {
                if let number = userInfo["tether"] as? String {
                    if let tether = UserController.sharedInstance.tethered.filter({$0.friend.number == number}).first {
                    }
                }
            }
        }
        completionHandler()
    }
    
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        let urlString = "\(url)"
        if urlString == "t3743" {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let navigationViewController = storyboard.instantiateViewControllerWithIdentifier("toMapViewControllerFromURLScheme") as! UINavigationController

            self.window?.rootViewController?.presentViewController(navigationViewController, animated: true, completion: nil)
        }
        return true
    }

}

