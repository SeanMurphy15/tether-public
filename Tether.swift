//
//  Tether.swift
//  Tether
//
//  Created by James Pacheco on 1/5/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation
import Firebase

class Tether {
    let identifier: String
    let friend: Friend
    var handle: FirebaseHandle? = nil
    
    init(identifier: String, friend: Friend) {
        self.identifier = identifier
        self.friend = friend
    }
}