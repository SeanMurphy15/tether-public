//
//  SignupViewController.swift
//  Tether
//
//  Created by Sean Murphy on 1/5/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import UIKit
import DigitsKit

class SignupViewController: UIViewController {
    
    @IBOutlet weak var greenRingView: UIImageView!
    
    @IBOutlet weak var tetherLogo: UIImageView!
    
    @IBOutlet weak var termsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        animateGreenRing()
        
        addTermsButtonTextAttributes()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func signupButtonTapped(sender: AnyObject) {
        
        verifyPhoneNumberWithDigits()
    }
    
    func verifyPhoneNumberWithDigits(){
        LocationController.shouldPromptForLocationAuthorization { (promptStatus) -> Void in
            switch promptStatus {
            case .Continue, .GoToSettings:
                let configuration = DGTAuthenticationConfiguration(accountFields: .DefaultOptionMask)
                configuration.appearance = DGTAppearance()
                
                configuration.appearance.logoImage = UIImage(named: "tether-logo-digits")
                
                configuration.appearance.labelFont = UIFont(name: "HelveticaNeue-Bold", size: 16)
                configuration.appearance.bodyFont = UIFont(name: "HelveticaNeue-Bold", size: 16)
                
                configuration.appearance.accentColor = UIColor.turquoiseColor()
                configuration.appearance.backgroundColor = UIColor.darkerGrayColor()
                
                Digits.sharedInstance().authenticateWithViewController(self, configuration: configuration) { (session, error) -> Void in
                    if (session != nil) {
                        
                        var number: String = session!.phoneNumber
                        if number.characters.count > 10 {
                            var numberArray: [Character] = Array(number.characters)
                            numberArray.removeFirst(numberArray.count - 10)
                            number = String(numberArray)
                        }
                        
                        print("USER PHONE NUMBER: \(number)")
                        
                        UserController.sharedInstance.currentUser = User(number: number)
                        
                        
                        self.dismissViewControllerAnimated(false, completion: nil)
                        
                        //TODO: "phoneNumber" can be used as property
                        
                    } else {
                        
                        // TODO: ERROR handle if user returns nil
                    }
                    
                }
            case .AuthorizeLocation:
                LocationController.authorizeLocationUse()
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
    
    func addTermsButtonTextAttributes() {
        let text = NSMutableAttributedString(string: "By verifying your number you agree to these terms.", attributes: [NSFontAttributeName: UIFont(name: "HelveticaNeue-Thin", size: 12)!, NSForegroundColorAttributeName: UIColor.lighterGrayColor()])
        text.addAttribute(NSForegroundColorAttributeName, value: UIColor.turquoiseColor(), range: NSRange(location: 38, length: 11))
        termsButton.setAttributedTitle(text, forState: .Normal)
    }
    
    
}
