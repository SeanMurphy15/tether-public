//
//  FriendController.swift
//  Tether
//
//  Created by James Pacheco on 1/5/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import UIKit
import CoreLocation

class FriendController {
    
    static func observeFriendLocation(friend: Friend, completion: (location: CLLocation?) -> Void) {
    
        completion(location: friend.location)
    }
    
    static func mockFriends() -> [Friend] {
        let friend1 = Friend(number: "+16038458967", firstName: "Josh", lastName: "Burt", picture: UIImage(named: "pink-circle")!, location: CLLocation(latitude: 50.0001, longitude: 70.0001))
        let friend2 = Friend(number: "+18015038649", firstName: "Zach", lastName: "Steed", picture: UIImage(named: "pink-circle")!, location: CLLocation(latitude: 50.0005, longitude: 70.0003))
        let friend3 = Friend(number: "+19095281860", firstName: "Sean", lastName: "Murphy", picture: UIImage(named: "pink-circle")!, location: CLLocation(latitude: 49.0009, longitude: 69.0009))
        
        return [friend1, friend2, friend3]
    }
    
    static func friendFromContacts(number: String) -> Friend {
        let friend = Friend(number: number)
        
        if let details = ContactController.sharedInstance.contacts[number] {
            if let firstName = details["firstName"] as? String {
                friend.firstName = firstName
            }
            
            if let lastName = details["lastName"] as? String {
                friend.lastName = lastName
            }
            
            if let imageData = details["imageData"] as? NSData,
                let image = UIImage(data: imageData) {
                    friend.picture = image
            }
            
            if let organizationName = details["organizationName"] as? String {
                friend.organizationName = organizationName
            }
        }
        return friend
    }
}