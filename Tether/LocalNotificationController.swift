//
//  LocalNotificationController.swift
//  Tether
//
//  Created by JB on 1/18/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import UIKit

class LocalNotificationController {

static let sharedInstance =  LocalNotificationController()

    enum Actions:String{
        case continueTether = "CONTINUE_TETHER"
        case cancelTether = "CANCEL_TETHER"
    }

    var categoryID:String{
        get{
            return "ACTIVE_TETHER_CATEGORY"
        }
    }

//    init() {
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "confirmLocalNotification:", name: "confirmPressed", object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "cancelLocalNotification:", name: "cancelPressed", object: nil)
//    }
//
    private func continueTetherConnection() {

        let continueTetherAction = UIMutableUserNotificationAction()
        continueTetherAction.identifier = "CONTINUE_ACTION"
        continueTetherAction.title = "Continue"
        continueTetherAction.activationMode = .Background
        continueTetherAction.authenticationRequired = false
        continueTetherAction.destructive = false

        let cancelTetherAction = UIMutableUserNotificationAction()
        cancelTetherAction.identifier = "CANCEL_ACTION"
        cancelTetherAction.title = "Untether"
        cancelTetherAction.activationMode = .Background
        cancelTetherAction.authenticationRequired = false
        cancelTetherAction.destructive = true

        let category = UIMutableUserNotificationCategory()
        category.identifier = "ACTIVE_TETHER_CATEGORY"
        category.setActions([continueTetherAction, cancelTetherAction], forContext: .Default)
        category.setActions([continueTetherAction, cancelTetherAction], forContext: .Minimal)

        if let categories = NSSet(object: category) as? Set<UIUserNotificationCategory> {
            let notifySettings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: categories)
            UIApplication.sharedApplication().registerUserNotificationSettings(notifySettings)
        }
    }

    func scheduleDeleteTetherNotifications(tether: Tether) {
        continueTetherConnection()
        if let fullName = tether.friend.fullName {
            let notification = UILocalNotification()
            notification.category = categoryID
            notification.fireDate = NSDate(timeIntervalSinceNow: 60*60)
            notification.alertBody = "Would you like to continue tethering with \(fullName)"
            notification.alertAction = "open"
            notification.hasAction = true
            notification.soundName = UILocalNotificationDefaultSoundName
            notification.timeZone = NSTimeZone.defaultTimeZone()
            notification.userInfo = ["tether": tether.friend.number]
            UIApplication.sharedApplication().scheduleLocalNotification(notification)
    //        notification.applicationIconBadgeNumber = UIApplication.sharedApplication().applicationIconBadgeNumber + 1
        }
    }

//    func scheduleTerminateAppNotification() {
//        let notification = UILocalNotification()
//        notification.category = categoryID
//        notification.fireDate = NSDate(timeIntervalSinceNow: 10) //60 Seconds
//        notification.alertTitle = "It's been 5 hours since you used Tether, so we closed it for you to save the environment"
//        notification.hasAction = false
//        notification.timeZone = NSTimeZone.defaultTimeZone()
//        UIApplication.sharedApplication().scheduleLocalNotification(notification)
//    }

    func localNotificationSettingAlert() {
        let notifySettings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(notifySettings)
    }

//    func confirmLocalNotification(notification: NSNotification) {
//
//    }
//    func cancelLocalNotification(notification: NSNotification) {
//    }

}

