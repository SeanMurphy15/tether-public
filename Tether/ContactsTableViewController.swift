//
//  ContactsTableViewController.swift
//  Tether
//
//  Created by Sean Murphy on 1/4/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import UIKit
import StoreKit

class ContactsTableViewController: UITableViewController, UISearchResultsUpdating{

    var searchController = UISearchController()
    
    lazy var priceFormatter: NSNumberFormatter = {
        let pf = NSNumberFormatter()
        pf.formatterBehavior = .Behavior10_4
        pf.numberStyle = .CurrencyStyle
        return pf
    }()
    
    var friendsUsingApp = ContactController.sharedInstance.friendsUsingApp.filter { (friend) -> Bool in
        var shouldShow = true
        if friend.number == UserController.sharedInstance.currentUser.number {
            shouldShow = false
        } else {
            for tether in UserController.sharedInstance.tethered {
                if tether.friend.number == friend.number {
                    shouldShow = false
                }
            }
            
            for requestedFriend in UserController.sharedInstance.requestsSent {
                if requestedFriend.number == friend.number {
                    shouldShow = false
                }
            }
            
            for friendRequested in UserController.sharedInstance.requestsReceived {
                if friendRequested.number == friend.number {
                    shouldShow = false
                }
            }
        }
        return shouldShow
    }

    var friendsNotUsingApp = ContactController.sharedInstance.friendsNotUsingApp.filter({$0.number != UserController.sharedInstance.currentUser.number})

    var products: [SKProduct] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: "tetherRequestAcceptedAlert", name: "tetherRequestAccepted", object: nil)
        setupSearchController()
        AppearanceController.setUpAppearance()
        tableView.rowHeight = 66
        let backView = UIView(frame: self.tableView.bounds)
        backView.backgroundColor = UIColor.darkerGrayColor()
        self.tableView.backgroundView = backView
        checkForProducts()
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


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func backButtonTapped(sender: AnyObject) {
        
        dismissViewControllerAnimated(true, completion: nil)
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
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.textColor = .whiteColor()
            header.textLabel?.textAlignment = .Center
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) { 
        if (UserController.sharedInstance.tethered.count > 0 || UserController.sharedInstance.requestsSent.count > 0) && !TetherProducts.store.isProductPurchased(products.first!.productIdentifier) {
            showActions()
        } else {
            switch indexPath.section {
            case 0:
                let friend = friendsUsingApp[indexPath.row]
                //let messageVC = composeTextMessageForTetherRequest("You have a Tether Request!", phoneNumbers: [friend.number], animated: true)
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
//                    UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
//                })
                self.backButtonTapped(self)
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
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: - Table view data source

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
        
        if let userCell = tableView.dequeueReusableCellWithIdentifier("contactCell", forIndexPath: indexPath) as? ContactCell {
            
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


    func setupSearchController() {

        let resultsViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("searchResults")

        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController.searchResultsUpdater = self
        searchController.searchBar.sizeToFit()
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.placeholder = "Search"
        searchController.hidesNavigationBarDuringPresentation = true
        definesPresentationContext = true
        searchController.searchBar.barStyle = .Black
        searchController.searchBar.keyboardAppearance = UIKeyboardAppearance.Dark
        searchController.searchBar.tintColor = UIColor.lighterGrayColor()




    }

    func updateSearchResultsForSearchController(searchController: UISearchController) {

        let searchTerm = searchController.searchBar.text!.lowercaseString

        let resultsViewController = searchController.searchResultsController as! SearchResultsTableViewController

        resultsViewController.friendsUsingApp = friendsUsingApp.filter({ $0.fullName!.lowercaseString.containsString(searchTerm)})
        resultsViewController.friendsNotUsingApp = friendsNotUsingApp.filter({ $0.fullName!.lowercaseString.containsString(searchTerm)})
        resultsViewController.tableView.reloadData()


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
