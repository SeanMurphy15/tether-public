//
//  RequestSentCell.swift
//  Tether
//
//  Created by Zach Steed on 1/7/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import UIKit

class RequestSentCell: UITableViewCell {

    @IBOutlet weak var friendImage: UIButton!
    
    @IBOutlet weak var requestLabel: UILabel!
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    var friend: Friend? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        friendImage.layer.cornerRadius = friendImage.frame.width/2
        friendImage.layer.borderColor = UIColor.turquoiseColor().CGColor
        friendImage.layer.borderWidth = 1
        cancelButton.setTitleColor(UIColor.redRejectColor(), forState: .Normal)
        friendImage.setTitleColor(.whiteColor(), forState: .Normal)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateWithFriend(friend:Friend) {
        self.friend = friend
        if let firstName = friend.firstName,
            lastName = friend.lastName {
                requestLabel.text = "Tether Pending..."
                requestLabel.textColor = UIColor.lighterGrayColor()
                nameLabel.text = "\(firstName) \(lastName)"
                nameLabel.textColor = UIColor.whiteColor()
        } else {
            requestLabel.text = "Tether Pending..."
            requestLabel.textColor = UIColor.lighterGrayColor()
            nameLabel.text = "\(friend.number)"
            nameLabel.textColor = UIColor.whiteColor()
        }
        
        if let image = friend.picture {
            friendImage.setBackgroundImage(image, forState: .Normal)
            friendImage.setTitle("", forState: .Normal)
        } else {
            friendImage.setBackgroundImage(UIImage(named: "tether-grey-circle"), forState: .Normal)
            friendImage.setTitle("\(initials())", forState: .Normal)
        }
    }

    @IBAction func cancelButtonTapped(sender: AnyObject) {
        if let friend = friend {
            TetherController.cancelRequest(friend, completion: { (success) -> Void in
                if success {
                    print("Successfully canceled request")
                }
            })
        }
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
}
