//
//  RequestsReceivedCell.swift
//  Tether
//
//  Created by Zach Steed on 1/7/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import UIKit

class RequestsReceivedCell: UITableViewCell {

    var delegate: RequestReceivedCellDelegate? = nil
    @IBOutlet weak var friendImage: UIButton!
    @IBOutlet weak var requestLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var acceptButton: UIButton!
    
    @IBOutlet weak var rejectButton: UIButton!
    var friend: Friend? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        friendImage.layer.cornerRadius = friendImage.frame.width/2
        friendImage.layer.borderColor = UIColor.turquoiseColor().CGColor
        friendImage.layer.borderWidth = 1
        rejectButton.setTitleColor(UIColor.redRejectColor(), forState: .Normal)
        acceptButton.setTitleColor(UIColor.turquoiseColor(), forState: .Normal)
        friendImage.setTitleColor(.whiteColor(), forState: .Normal)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func acceptButtonTapped(sender: AnyObject) {
        if let friend = friend {
            if let delegate = delegate {
                delegate.acceptTether(friend)
            }
        }
    }
    
    @IBAction func rejectButtonTapped(sender: AnyObject) {
        if let friend = friend {
            TetherController.rejectRequest(friend, completion: { (success) -> Void in
                if success {
                    print("Successfully rejected request")
                }
            })
        }
    }
    
    func updateWithFriend(friend:Friend) {
        self.friend = friend
        if let firstName = friend.firstName,
            lastName = friend.lastName {
                nameLabel.text = "\(firstName) \(lastName)"
                nameLabel.textColor = UIColor.whiteColor()
                requestLabel.text = "\(firstName) requested to Tether"
                requestLabel.textColor = UIColor.lighterGrayColor()
        } else {
            nameLabel.text = "\(friend.number)"
            nameLabel.textColor = UIColor.whiteColor()
            requestLabel.text = "An unknown number requested to Tether"
            requestLabel.textColor = UIColor.lighterGrayColor()
        }
        
        if let image = friend.picture {
            friendImage.setBackgroundImage(image, forState: .Normal)
            friendImage.setTitle("", forState: .Normal)
        } else {
            friendImage.setBackgroundImage(UIImage(named: "tether-grey-circle"), forState: .Normal)
            friendImage.setTitle("\(initials())", forState: .Normal)
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

protocol RequestReceivedCellDelegate {
    func acceptTether(friend: Friend)
}

