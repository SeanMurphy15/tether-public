//
//  ParseUser.swift
//  Tether
//
//  Created by Sean Murphy on 1/20/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation
import Parse

class ParseUser: PFObject, PFSubclassing{

    @NSManaged var phoneNumber: String
    @NSManaged var friends: [String]


    class func initalize() {

        struct Static {

            static var onceToken : dispatch_once_t = 0;
        }

        dispatch_once(&Static.onceToken) {

            self.registerSubclass()
        }

    }



    class func parseClassName() -> String {
        return "ParseUser"
    }
}
