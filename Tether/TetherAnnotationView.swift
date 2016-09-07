//
//  TetherAnnotationView.swift
//  Tether
//
//  Created by James Pacheco on 1/13/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import UIKit
import MapKit

class TetherAnnotationView: MKAnnotationView {

    let button = UIButton()
    
    init(annotation: TetherAnnotation) {
        super.init(annotation: annotation, reuseIdentifier: "TetherAnnotationView")
        self.image = UIImage(named: "annotation")
        self.frame.size = CGSizeMake(50, 50)
        self.contentMode = .ScaleAspectFill
        self.addSubview(button)
        button.frame = CGRectMake(7, 1, 36, 36)
        self.sendSubviewToBack(button)
        button.imageView?.contentMode = .ScaleAspectFill
        button.layer.cornerRadius = button.frame.width / 2
        button.clipsToBounds = true
        let firstName = annotation.tether.friend.firstName ?? ""
        let lastName = annotation.tether.friend.lastName ?? ""
        let company = annotation.tether.friend.organizationName ?? ""
        let firstInitial = firstName.characters.count > 0 ? String(firstName.characters.first!).uppercaseString:""
        let lastInitial = lastName.characters.count > 0 ? String(lastName.characters.first!).uppercaseString:""
        let companyInitial = company.characters.count > 0 ? String(company.characters.first!).uppercaseString:""
        let title = (firstInitial + lastInitial).characters.count > 0 ? (firstInitial + lastInitial):companyInitial
        if let picture = annotation.tether.friend.picture {
            button.setBackgroundImage(picture, forState: .Normal)
        } else {
            button.setTitle(title, forState: .Normal)
            button.backgroundColor = UIColor.lighterGrayColor()
        }
        button.userInteractionEnabled = false
        self.userInteractionEnabled = true
        self.canShowCallout = true
        
        
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

}
