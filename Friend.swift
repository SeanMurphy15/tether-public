//
//  Friend.swift
//  Tether
//
//  Created by James Pacheco on 1/5/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import UIKit
import CoreLocation

class Friend {
    let number: String
    var firstName: String?
    var lastName: String?
    var picture: UIImage?
    var organizationName: String?
    var location: CLLocation?
    var distance: Double? {
        get{
            guard let friendLocation = location,
                userLocation = UserController.sharedInstance.currentUser.location else {return nil}
            return userLocation.distanceFromLocation(friendLocation)
        }
    }
    var fullName: String? {
        if let firstName = firstName,
            lastName = lastName {
                return "\(firstName) \(lastName)"
        } else {
            return nil
        }
    }
    
    init(number: String, firstName: String? = nil, lastName: String? = nil, picture: UIImage? = nil, organizationName: String? = nil, location: CLLocation? = nil) {
        self.number = number
        self.firstName = firstName
        self.lastName = lastName
        self.picture = picture
        self.organizationName = organizationName
        self.location = location
    }

    
}