//
//  User.swift
//  Tether
//
//  Created by James Pacheco on 1/5/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation
import CoreLocation

class User {
    let number: String
    var location: CLLocation? {
        didSet {
            if let _ = location {
                FirebaseController.setValueAtEndpoint(locationEndpoint, value: locationJson) { (success) -> Void in
                    if !success {
                        print("Location not updating to firebase")
                    }
                }
            }
        }
    }
    
    init(number: String, location: CLLocation? = nil) {
        self.number = number
        self.location = location
    }
}
extension User {
    var locationJson: [String:AnyObject] {
        var json: [String: AnyObject] = [:]
        if let location = self.location {
            json = ["lat": location.coordinate.latitude, "lon": location.coordinate.longitude]
            if let floor = location.floor {
                json["floor"] = floor
            }
        }
        return json
    }
    var locationEndpoint: String {
        return "locations/\(number)"
    }

    var numberJson:[String:AnyObject] {
        return [(number):true]
    }
    var numberEndpoint: String {
        return "numbers"
    }
}