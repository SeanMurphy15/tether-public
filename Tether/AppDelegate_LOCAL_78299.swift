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


            let preBackgroundPush = !application.respondsToSelector("backgroundRefreshStatus")
            let oldPushHandlerOnly = !self.respondsToSelector("application:didReceiveRemoteNotification:fetchCompletionHandler:")
            var pushPayload = false
            if let options = launchOptions {
                pushPayload = options[UIApplicationLaunchOptionsRemoteNotificationKey] != nil
            }
            if (preBackgroundPush || oldPushHandlerOnly || pushPayload) {
                PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
            }
        }
        if #available(iOS 8.0, *) {
            let types: UIUserNotificationType = [.Alert, .Badge, .Sound]
            let settings = UIUserNotificationSettings(forTypes: types, categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        } else {
            let types: UIRemoteNotificationType = [.Alert, .Badge, .Sound]
            application.registerForRemoteNotificationTypes(types)
        }
        // [Optional] Power your app with Local Datastore. For more info, go to
        // https://parse.com/docs/ios/guide#local-datastore
        Parse.enableLocalDatastore()

        // Initialize Parse.
        Parse.setApplicationId("tS45oYEmOdSnNa3sh9fvCpciwiAnibWvFi2BSCsX",
            clientKey: "jsymaO3MXzAKFyiTUcP6gezBcrv6hA3ZcrMhZHzO")

        // [Optional] Track statistics around application opens.
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
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
        
        application.applicationIconBadgeNumber = application.applicationIconBadgeNumber + 1
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
        PFPush.handlePush(userInfo)
        if application.applicationState == UIApplicationState.Inactive {
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
        }
    }



    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        LocationController.sharedInstance.locationManager.distanceFilter = 10
        LocationController.sharedInstance.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        application.applicationIconBadgeNumber = 0
    }

    func applicationWillEnterForeground(application: UIApplication) {
        LocationController.sharedInstance.locationManager.distanceFilter = 1
        LocationController.sharedInstance.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        application.applicationIconBadgeNumber = 0
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {

        let urlString = "\(url)"

        if urlString == "t3743"

        {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let navigationViewController = storyboard.instantiateViewControllerWithIdentifier("toMapViewControllerFromURLScheme") as! UINavigationController

            self.window?.rootViewController?.presentViewController(navigationViewController, animated: true, completion: nil)

        }




        return true
    }

}

