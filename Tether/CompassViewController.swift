//
//  CompassViewController.swift
//  Tether
//
//  Created by Sean Murphy on 1/4/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import UIKit
import CoreLocation
import MessageUI

class CompassViewController: UIViewController, MFMessageComposeViewControllerDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    var tether: Tether? = nil
    var nearMessage = ""
    @IBOutlet weak var arrow: UIImageView!
    @IBOutlet weak var distanceFromContactLabel: UILabel!
    @IBOutlet weak var greenRingView: UIImageView!

    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var radarView: UIImageView!
    @IBOutlet weak var mainCircle: UIImageView!
  


    override func viewDidLoad() {
        super.viewDidLoad()
        nearMessage = generateMessage()

        LocationController.sharedInstance.locationManager.startUpdatingHeading()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CompassViewController.updateDistanceToFriend), name: "userLocationChanged", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CompassViewController.updateDistanceToFriend), name: "friendLocationChanged", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CompassViewController.updateCompassLocationOfFriend), name: "userHeadingChanged", object: nil)

        AppearanceController.setUpAppearance()
        animateRadar()
        setViewToFriend()


    }

    override func viewWillAppear(animated: Bool) {
        LocationController.sharedInstance.locationManager.startUpdatingHeading()
        updateDistanceToFriend()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func animateArrowAndDistance(userLocation: CLLocation, target: CLLocation, heading: CLLocationDirection){
        let degrees = LocationController.sharedInstance.getHeadingBetweenTwoPoints(userLocation, target: target)
        print("heading between devices \(degrees)")
        print("device heading \(heading)")
        let finalDegrees = (degrees - heading) > 0 ? (degrees - heading):(degrees - heading + 360)
        let radians = LocationController.sharedInstance.degreesToRadians(finalDegrees)

        UIView.animateWithDuration(1.0, delay: 0.0, usingSpringWithDamping: 5.0, initialSpringVelocity: 5.0, options: .CurveLinear, animations: { () -> Void in
            self.arrow.transform = CGAffineTransformMakeRotation(CGFloat(radians))
            }) { (_) -> Void in

                // self.updateCompassLocationOfFriend()
        }

    }

    func formatDistanceLabel(distance: Float){
        let distanceInMeters = String(Int(distance))
        distanceFromContactLabel.text = distanceInMeters + " meters"
        if distance > 1000 {
            let distanceInKilometers = String((Int(distance / 1000)))
            distanceFromContactLabel.text = distanceInKilometers + " Km"


        }
        if distance < 25 {

            distanceFromContactLabel.text = nearMessage
            mainCircle.hidden = true
            arrow.hidden = true
            radarView.stopAnimating()
            animateGreenRing()

        } else {

            mainCircle.hidden = false
            arrow.hidden = false
            radarView.startAnimating()
            greenRingView.stopAnimating()

        }
    }

    func updateCompassLocationOfFriend(){
        if let tether = tether,
            friendLocation = tether.friend.location,
            userLocation = LocationController.sharedInstance.locationManager.location,
            userHeading = LocationController.sharedInstance.locationManager.heading {
                if userHeading.headingAccuracy > 0 {
                    let heading = userHeading.trueHeading > 0 ? userHeading.trueHeading:userHeading.magneticHeading
                    animateArrowAndDistance(userLocation, target: friendLocation, heading: heading)
                }
        }
    }
    
    func updateDistanceToFriend() {
        if let tether = tether,
            friendLocation = tether.friend.location,
            userLocation = LocationController.sharedInstance.locationManager.location {
                let distance = Float(userLocation.distanceFromLocation(friendLocation))
                formatDistanceLabel(distance)
        }

    }

    func setViewToFriend(){

        if let friendName = tether?.friend.firstName {

            titleLabel.text = "\(friendName)"
            messageButton.setTitle("Message \(friendName)", forState: UIControlState.Normal)
        }

        if let friendLocation = tether?.friend.location {

        LocationController.sharedInstance.findAddressOfLocation(friendLocation) { (approximateAddress) -> Void in

            self.addressLabel.text = approximateAddress

            }
        }
    }


    func animateGreenRing(){

        greenRingView.animationImages = [
            UIImage(named: "r1")!,
            UIImage(named: "r2")!,
            UIImage(named: "r3")!,
            UIImage(named: "r4")!,
            UIImage(named: "r5")!,
            UIImage(named: "r6")!,
            UIImage(named: "r7")!,
            UIImage(named: "r8")!,
            UIImage(named: "r9")!,
            UIImage(named: "r10")!,
            UIImage(named: "r11")!
        ]

        greenRingView.animationDuration = 0.75
        greenRingView.animationRepeatCount = 0
        greenRingView.startAnimating()
    }




    func animateRadar(){

        radarView.animationImages = [
            UIImage(named: "c1")!,
            UIImage(named: "c2")!,
            UIImage(named: "c3")!,
            UIImage(named: "c4")!,
            UIImage(named: "c5")!,
            UIImage(named: "c6")!
            
        ]
        
        radarView.animationDuration = 0.5
        radarView.animationRepeatCount = 0
        radarView.startAnimating()
    }

    @IBAction func composeMessageButtonTapped(sender: AnyObject) {

        if let friendPhoneNumber = tether?.friend.number {
            let vc = composeTextMessage(friendPhoneNumber, animated: true)

            presentViewController(vc, animated: true, completion: { () -> Void in
                UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
            })


        } else {

            let unableToSendAlert = UIAlertController(title: "Unable to Send Message", message: "", preferredStyle: .Alert)
            let unableToSendAlertConfirmation =  UIAlertAction(title: "OK", style: .Cancel, handler: nil)
            unableToSendAlert.addAction(unableToSendAlertConfirmation)

        }

    }
    
    func composeTextMessage(phoneNumber: String, animated: Bool) -> UIViewController {
        if MFMessageComposeViewController.canSendText() {
            let messageComposeVC = MFMessageComposeViewController()


            messageComposeVC.messageComposeDelegate = self
            messageComposeVC.body = ""
            messageComposeVC.recipients = [phoneNumber]


            return messageComposeVC

        } else {

            let unableToSendAlert = UIAlertController(title: "Unable to Send Message", message: "", preferredStyle: .Alert)
            let unableToSendAlertConfirmation =  UIAlertAction(title: "OK", style: .Cancel, handler: nil)
            unableToSendAlert.addAction(unableToSendAlertConfirmation)

            return unableToSendAlert

        }
    }


    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {

        self.dismissViewControllerAnimated(false, completion: nil)
        dismissViewControllerAnimated(true, completion: nil)
    }


    func generateMessage() -> String{

        if let friend = tether?.friend {
            let name = friend.firstName != nil ? friend.firstName!:(friend.lastName != nil ? friend.lastName!:(friend.organizationName ?? "your friend"))
        let messageArray = ["Jump up and down and scream! \(name) is here!","\(name) is close by! Give em' a scare!","Get on a table and and dance! \(name) is nearby!","Do you see \(name) yet?"]

        let generatedMessage = Int(arc4random_uniform(UInt32(messageArray.count)))

        let result = messageArray[generatedMessage]

        return result
        }
        return ""
    }

    
    @IBAction func backButtonTapped(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
}







