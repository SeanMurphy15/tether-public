//
//  ParseController.swift
//  Tether
//
//  Created by Sean Murphy on 1/19/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation
import Parse




class ParseController{

    static func sendPushNotification(friend: Friend) {
        if let friendFullName = friend.fullName {
            PFCloud.callFunctionInBackground("enablePushNotification", withParameters: ["userPhone" : UserController.sharedInstance.currentUser.number, "friendPhone" : friend.number, "friendName" : " \(friendFullName)!"]) { (_, error) -> Void in
                if let _ = error {
                    //SEND TEXT YA BISH

                }
            }
        } else {
            PFCloud.callFunctionInBackground("enablePushNotification", withParameters: ["userPhone" : UserController.sharedInstance.currentUser.number, "friendPhone" : friend.number, "friendName" : "!"]) { (_, error) -> Void in
                if let _ = error {
                    //SEND TEXT YA BISH
                }
            }
        }
    }

    static func saveUsersDevice() {

        let installation = PFInstallation.currentInstallation()
        installation["phoneNumber"] = UserController.sharedInstance.currentUser.number

        installation.saveInBackgroundWithBlock { (succes, error) -> Void in
            let parseUser = ParseUser()
            parseUser.phoneNumber = UserController.sharedInstance.currentUser.number
            let friendsArray = ContactController.sharedInstance.friendsUsingApp + ContactController.sharedInstance.friendsNotUsingApp
            parseUser.friends = friendsArray.map(){ $0.number }

            parseUser.saveInBackgroundWithBlock({ (_, _) -> Void in
            })
        }

    }
    
    static func registerPush(application: UIApplication, launchOptions: [NSObject: AnyObject]?) {
        
    }


    
}