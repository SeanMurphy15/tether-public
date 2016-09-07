//
//  FriendAnnotation.swift
//  Tether
//
//  Created by Sean Murphy on 1/8/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import UIKit
import MapKit

class FriendAnnotation: NSObject, MKAnnotation {

    var coordinate: CLLocationCoordinate2D
    var firsName: String?
    var lastName: String?
    var picture: UIImage?


    init(coordinate: CLLocationCoordinate2D, firstName: String?, lastName: String?, picture: UIImage?){

        self.coordinate = coordinate
        self.firsName = firstName
        self.lastName = lastName
        self.picture = picture
    }

}
