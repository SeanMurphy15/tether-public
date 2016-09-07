//
//  infoViewController.swift
//  Tether
//
//  Created by James Pacheco on 1/18/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import UIKit
import StoreKit

class infoViewController: UIViewController {

    @IBOutlet weak var upgradeButton: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    lazy var priceFormatter: NSNumberFormatter = {
        let pf = NSNumberFormatter()
        pf.formatterBehavior = .Behavior10_4
        pf.numberStyle = .CurrencyStyle
        return pf
    }()
    
    var products: [SKProduct] = [] {
        didSet {
            if products.count > 0 {
                priceFormatter.locale = products.first!.priceLocale
                let price = priceFormatter.stringFromNumber(products.first!.price)
                upgradeButton.setTitle("Upgrade \(price!)/Restore", forState: .Normal)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        checkForProducts()
        AppearanceController.setUpAppearance()
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
    
    @IBAction func buyButtonTapped(sender: AnyObject) {
        let product = products.first!
        let payment = SKPayment(product: product)
        SKPaymentQueue.defaultQueue().addPayment(payment)
    }
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }


}
