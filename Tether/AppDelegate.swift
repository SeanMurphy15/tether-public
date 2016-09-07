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
import Parse
import Bolts
import Firebase


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        ParseUser.registerSubclass()
        if application.applicationState != UIApplicationState.Background {
            // Track an app open here if we launch with a push, unless
            // "content_available" was used to trigger a background push (introduced in iOS 7).
            // In that case, we skip tracking here to avoid double counting the app-open.
            
            application.applicationIconBadgeNumber = 0
            
            
            let preBackgroundPush = !application.respondsToSelector(Selector("backgroundRefreshStatus"))
            let oldPushHandlerOnly = !self.respondsToSelector(#selector(UIApplicationDelegate.application(_:didReceiveRemoteNotification:fetchCompletionHandler:)))
            var pushPayload = false
            if let options = launchOptions {
                pushPayload = options[UIApplicationLaunchOptionsRemoteNotificationKey] != nil
            }
            if (preBackgroundPush || oldPushHandlerOnly || pushPayload) {
                PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
            }
        }
        
        let types: UIUserNotificationType = [.Alert, .Badge, .Sound]
        let settings = UIUserNotificationSettings(forTypes: types, categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
        // [Optional] Power your app with Local Datastore. For more info, go to
        // https://parse.com/docs/ios/guide#local-datastore
        Parse.enableLocalDatastore()
        
        // Initialize Parse.
        Parse.setApplicationId("tS45oYEmOdSnNa3sh9fvCpciwiAnibWvFi2BSCsX",
            clientKey: "jsymaO3MXzAKFyiTUcP6gezBcrv6hA3ZcrMhZHzO")
        
        // [Optional] Track statistics around application opens.
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        //        if let options = launchOptions {
        //            if let notification = options[UIApplicationLaunchOptionsLocalNotificationKey] as? UILocalNotification {
        //                if let userInfo = notification.userInfo {
        //                    let message = userInfo["Message"] as! String
        //                }
        //            }
        //        }
        application.applicationIconBadgeNumber = 0
        
        
        //ParseController.registerPush(application, launchOptions: launchOptions)
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
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        
        //        application.applicationIconBadgeNumber = application.applicationIconBadgeNumber + 1
        let installation = PFInstallation.currentInstallation()
        
        installation.setDeviceTokenFromData(deviceToken)
        installation.channels = ["global"]
        installation.saveInBackground()
        
        
        
        
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        if error.code == 3010 {
            print("Push notifications are not supported in the iOS Simulator.")
        } else {
            print("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
        }
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        application.applicationIconBadgeNumber = application.applicationIconBadgeNumber + 1
        PFPush.handlePush(userInfo)
        if application.applicationState == UIApplicationState.Inactive {
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
        }
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
        application.applicationIconBadgeNumber = 0
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        LocationController.sharedInstance.locationManager.distanceFilter = 5
        LocationController.sharedInstance.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        //        application.applicationIconBadgeNumber = 0
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        LocationController.sharedInstance.isInBackground = false
        application.applicationIconBadgeNumber = 0
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

