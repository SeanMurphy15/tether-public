//
//  MessageController.swift
//  Tether
//
//  Created by Sean Murphy on 1/6/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation
import UIKit
import MessageUI

extension UITableViewController: MFMessageComposeViewControllerDelegate {

    func composeTextMessageForTetherRequest(message: String, phoneNumbers: [String], animated: Bool) -> UIViewController {

        if MFMessageComposeViewController.canSendText() {
            let messageComposeVC = MFMessageComposeViewController()

            let url = "t3743"
            
            messageComposeVC.messageComposeDelegate = self
            messageComposeVC.body = "\(message) tether://\(url)"
            messageComposeVC.recipients = phoneNumbers

            return messageComposeVC

        } else {

            let unableToSendAlert = UIAlertController(title: "Unable to Send Message", message: "", preferredStyle: .Alert)
            let unableToSendAlertConfirmation =  UIAlertAction(title: "OK", style: .Cancel, handler: nil)
            unableToSendAlert.addAction(unableToSendAlertConfirmation)

            return unableToSendAlert

        }
    }


    func composeTextMessageForAppStore(message: String, phoneNumber: String, animated: Bool) -> UIViewController {
        if MFMessageComposeViewController.canSendText() {
            let messageComposeVC = MFMessageComposeViewController()

            // TODO: - Add Appstore URL for Tether
            let url = "https://itunes.apple.com/us/app/tether-keep-your-friends-close/id1081638285?mt=8"

            messageComposeVC.messageComposeDelegate = self
            messageComposeVC.body = "\(message) \(url)"
            messageComposeVC.recipients = [phoneNumber]


            return messageComposeVC

        } else {

            let unableToSendAlert = UIAlertController(title: "Unable to Send Message", message: "", preferredStyle: .Alert)
            let unableToSendAlertConfirmation =  UIAlertAction(title: "OK", style: .Cancel, handler: nil)
            unableToSendAlert.addAction(unableToSendAlertConfirmation)

            return unableToSendAlert
            
        }
    }
    
    
    public func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        if let presentingViewController = self.presentingViewController as? ContactsTableViewController {
            dismissViewControllerAnimated(true) {
                presentingViewController.backButtonTapped(self)
                presentingViewController.backButtonTapped(self)
            }
        } else {
            self.dismissViewControllerAnimated(false, completion: nil)
            dismissViewControllerAnimated(true, completion: nil)
        }
    }


}

