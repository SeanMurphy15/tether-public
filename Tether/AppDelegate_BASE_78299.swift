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

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        LocationController.sharedInstance.locationManager.distanceFilter = 10
        LocationController.sharedInstance.locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func applicationWillEnterForeground(application: UIApplication) {
        LocationController.sharedInstance.locationManager.distanceFilter = 1
        LocationController.sharedInstance.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
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

