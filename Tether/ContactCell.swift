//
//  ContactCell.swift
//  Tether
//
//  Created by Zach Steed on 1/7/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import UIKit

class ContactCell: UITableViewCell {

    @IBOutlet weak var imageContact: UIButton!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var requestButton: UIButton!


    var isUser: Bool = false
    var friend: Friend? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageContact.layer.cornerRadius = imageContact.frame.width/2
        imageContact.layer.borderColor = UIColor.turquoiseColor().CGColor
        imageContact.layer.borderWidth = 1
        imageContact.setTitleColor(.whiteColor(), forState: .Normal)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initials() ->String {
        var initialsString = String()
        if let firstName = friend?.firstName where firstName.characters.count > 0 {
            initialsString += firstName.substringToIndex(firstName.startIndex.successor())
        }
        
        if let lastName = friend?.lastName where lastName.characters.count > 0 {
            initialsString += lastName.substringToIndex(lastName.startIndex.successor())
        }
        
        if let organizationName = friend?.organizationName where organizationName.characters.count > 0 {
            initialsString += organizationName.substringToIndex(organizationName.startIndex.successor())
        }
        
        return initialsString.uppercaseString
    }
    
    func updateForUser(friend:Friend) {
        self.friend = friend
        isUser = true
        var firstName = ""
        var lastName = ""
        var organizationName = ""
        if let name = friend.firstName {
            firstName = name
        }
        
        if let name = friend.lastName {
            lastName = name
        }
        
        if let name = friend.organizationName {
            organizationName = name
        }
        
        if friend.firstName?.characters.count == 0 && friend.lastName?.characters.count == 0 {
            fullNameLabel.text = organizationName
        } else {
            fullNameLabel.text = firstName + " " + lastName
        }
        
        phoneNumberLabel.text = friend.number
        phoneNumberLabel.textColor = UIColor.lighterGrayColor()
        fullNameLabel.textColor = UIColor.whiteColor()
        
        if let picture = friend.picture {
            imageContact.setBackgroundImage(picture, forState: .Normal)
            imageContact.setTitle("", forState: .Normal)
        } else {
            imageContact.setTitle("\(initials())", forState: .Normal)
            imageContact.setBackgroundImage(UIImage(named: "tether-grey-circle"), forState: .Normal)
        }
        
        requestButton.setTitle("Tether", forState: .Normal)
        requestButton.setTitleColor(UIColor.turquoiseColor(), forState: .Normal)
    }
    
    func updateForNonUser(friend:Friend) {
        self.friend = friend
        isUser = false
        var firstName = ""
        var lastName = ""
        var organizationName = ""
        if let name = friend.firstName {
            firstName = name
        }
        
        if let name = friend.lastName {
            lastName = name
        }
        
        if let name = friend.organizationName {
            organizationName = name
        }
        if friend.firstName?.characters.count == 0 && friend.lastName?.characters.count == 0 {
            fullNameLabel.text = organizationName
        } else {
            fullNameLabel.text = firstName + " " + lastName
        }

        phoneNumberLabel.text = friend.number
        phoneNumberLabel.textColor = UIColor.lighterGrayColor()
        fullNameLabel.textColor = UIColor.whiteColor()
        
        if let picture = friend.picture {
            imageContact.setTitle("", forState: .Normal)
            imageContact.setBackgroundImage(picture, forState: .Normal)
        } else {
            imageContact.setBackgroundImage(UIImage(named: "tether-grey-circle"), forState: .Normal)
            imageContact.setTitle("\(initials())", forState: .Normal)
        }


        requestButton.setTitleColor(UIColor.lighterGrayColor(), forState: .Normal)
        requestButton.setTitle("Invite", forState: .Normal)
        
    }
}
