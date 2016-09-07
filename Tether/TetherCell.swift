//
//  TetherCell.swift
//  Tether
//
//  Created by Zach Steed on 1/7/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import UIKit

class TetherCell: UITableViewCell {

    @IBOutlet weak var friendImage: UIButton!
    
    @IBOutlet weak var untetherButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tetherLabel: UILabel!
    
    var tether: Tether? = nil
    var friend: Friend? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        friendImage.layer.cornerRadius = friendImage.frame.width/2
        friendImage.layer.borderColor = UIColor.turquoiseColor().CGColor
        friendImage.layer.borderWidth = 1
        untetherButton.setTitleColor(UIColor.redRejectColor(), forState: .Normal)
        friendImage.setTitleColor(.whiteColor(), forState: .Normal)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateWithTether(tether: Tether) {
        self.tether = tether
        if let firstName = tether.friend.firstName,
            lastName = tether.friend.lastName {
                nameLabel.text = "\(firstName) \(lastName)"
                nameLabel.textColor = UIColor.whiteColor()
                tetherLabel.text = "Tethered"
                tetherLabel.textColor = UIColor.lighterGrayColor()
        } else if tether.friend.firstName?.characters.count == 0 && tether.friend.lastName?.characters.count == 0 {
            nameLabel.text = "\(tether.friend.organizationName)"
            nameLabel.textColor = UIColor.whiteColor()
            tetherLabel.text = "Tethered"
            tetherLabel.textColor = UIColor.lighterGrayColor()
        } else {
            nameLabel.text = "\(tether.friend.number)"
            nameLabel.textColor = UIColor.whiteColor()
            tetherLabel.text = "Tethered"
            tetherLabel.textColor = UIColor.lighterGrayColor()
        }
        
        if let image = tether.friend.picture {
            friendImage.setBackgroundImage(image, forState: .Normal)
            friendImage.setTitle("", forState: .Normal)
        } else {
            friendImage.setBackgroundImage(UIImage(named: "tether-grey-circle"), forState: .Normal)
            friendImage.setTitle("\(initials())", forState: .Normal)
        }
    }

    @IBAction func untetherButtonTapped(sender: AnyObject) {
        if let tether = tether {
            TetherController.removeTether(tether, completion: { (success) -> Void in
                if !success {
                    print("untether button didn't work")
                }
            })
        }
    }
    
    func initials() ->String {
        var initialsString = String()
        if let firstName = tether?.friend.firstName where firstName.characters.count > 0 {
            initialsString += firstName.substringToIndex(firstName.startIndex.successor())
        }
        
        if let lastName = tether?.friend.lastName where lastName.characters.count > 0 {
            initialsString += lastName.substringToIndex(lastName.startIndex.successor())
        }
        
        if let organizationName = tether?.friend.organizationName where organizationName.characters.count > 0 {
            initialsString += organizationName.substringToIndex(organizationName.startIndex.successor())
        }
        
        return initialsString.uppercaseString
    }

}
