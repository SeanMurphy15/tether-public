//
//  SearchResultsTableViewController.swift
//  Tether
//
//  Created by Sean Murphy on 1/7/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import UIKit
import StoreKit

class SearchResultsTableViewController: UITableViewController {

    var friendsNotUsingApp: [Friend] = []
    var friendsUsingApp: [Friend] = []

    lazy var priceFormatter: NSNumberFormatter = {
        let pf = NSNumberFormatter()
        pf.formatterBehavior = .Behavior10_4
        pf.numberStyle = .CurrencyStyle
        return pf
    }()
    
    var products: [SKProduct] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.setNeedsDisplay()
        tableView.setNeedsLayout()
        AppearanceController.setUpAppearance()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.rowHeight = 66
        
        checkForProducts()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkForProducts() {
        products = []
        TetherProducts.store.requestProductsWithCompletionHandler { (success, products) -> () in
            if success {
                self.products = products
            } else {
                print("There are no products in the store")
            }
        }
    }

    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Friends using Tether"
        case 1:
            return "Friends you should make use Tether"
        default:
            return nil
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (UserController.sharedInstance.tethered.count > 0 || UserController.sharedInstance.requestsSent.count > 0) && !TetherProducts.store.isProductPurchased(products.first!.productIdentifier) {
            showActions()
        } else {
            switch indexPath.section {
            case 0:
                let friend = friendsUsingApp[indexPath.row]
//                let messageVC = composeTextMessageForTetherRequest("You have a Tether Request!", phoneNumbers: [friend.number], animated: true)
                TetherController.requestTether(friend, completion: { (success, approved) -> Void in
                    if success {
                        if let approved = approved {
                            if approved {
                                TetherController.createTether(friend, completion: { (success) -> Void in
                                    if success {
                                        print("Tether successfully created")
                                    }
                                })
                            }
                        } else {
                            print("Request rejected")
                        }
                    }
                })
//                presentViewController(messageVC, animated: true, completion: { () -> Void in
//                    
//                })
                if let presentingViewController = self.presentingViewController as? ContactsTableViewController {
                    presentingViewController.backButtonTapped(self)
                    presentingViewController.backButtonTapped(self)
                }
            case 1:
                let friend = friendsNotUsingApp[indexPath.row]
                let messageVC = composeTextMessageForAppStore("Your friend wants your to join Tether", phoneNumber: friend.number, animated: true)
                presentViewController(messageVC, animated: true, completion: { () -> Void in
                    
                })
                //self.backButtonTapped(self)
            default:
                break
            }
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)    }

    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.textColor = .whiteColor()
            header.textLabel?.textAlignment = .Center
        }
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        switch section {
        case 0:
            return friendsUsingApp.count
        case 1:
            return friendsNotUsingApp.count
        default:
            return 0
        }
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        if let userCell = tableView.dequeueReusableCellWithIdentifier("searchResultCell", forIndexPath: indexPath) as? ContactCell {

            switch indexPath.section {
            case 0:
                let friend = friendsUsingApp[indexPath.row]
                userCell.updateForUser(friend)
            case 1:
                let friend = friendsNotUsingApp[indexPath.row]
                userCell.updateForNonUser(friend)
            default:
                break
            }
            return userCell
        }
        return UITableViewCell()
    }

    func showActions() {
        if let product = products.first {
            if TetherProducts.store.isProductPurchased(product.productIdentifier) {
                let alreadyPurchasedAlert = UIAlertController(title: "Previously Purchased Premium Package", message: "", preferredStyle: .Alert)
                let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alreadyPurchasedAlert.addAction(okAction)
                presentViewController(alreadyPurchasedAlert, animated: true, completion: nil)
                
            } else if let price = priceFormatter.stringFromNumber(product.price){
                priceFormatter.locale = product.priceLocale
                let alert = UIAlertController(title: "Purchase Tether Premium...\(price)", message: "You cannot have more than one Tether or outstanding Tether Request unless you upgrade.", preferredStyle: .Alert)
                let buyAction = UIAlertAction(title: "Buy", style: .Cancel) { (action) -> Void in
                    let payment = SKPayment(product: product)
                    SKPaymentQueue.defaultQueue().addPayment(payment)
                }
                let cancelAction = UIAlertAction(title: "Stick with one Tether", style: .Default) { (action) -> Void in
                }
                alert.addAction(buyAction)
                alert.addAction(cancelAction)
                
                presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
  
}
