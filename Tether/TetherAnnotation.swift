//
//  TetherAnnotation.swift
//  Tether
//
//  Created by JB on 1/12/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import UIKit
import MapKit

class TetherAnnotation: MKPointAnnotation {

    let tether: Tether
    
    init(tether: Tether) {
        self.tether = tether
        super.init()
        let friend = tether.friend
        if let location = friend.location {
            self.coordinate = location.coordinate
            self.title = friend.fullName
        }
    }
}
