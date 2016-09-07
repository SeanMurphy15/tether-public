////
////  IAPHelper.swift
////  Tether
//
//  Created by JB on 1/14/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import StoreKit
import UIKit

var products = [SKProduct]()

public let IAPHelperProductPurchaseNotification = "IAPHelperProductPurchasedNotification"
public typealias ProductIdentifier = String
public typealias RequestProductsCompletionHandler = (success: Bool, products: [SKProduct]) -> ()
public class IAPHelper: NSObject {
    
    private let productIdentifiers: Set<ProductIdentifier> 
    private var purchasedProductIdentifiers = Set<ProductIdentifier>()
    
    private var productsRequest: SKProductsRequest?
    private var completionHandler: RequestProductsCompletionHandler?


    public init(productIdentifiers: Set<ProductIdentifier>) {
        
        self.productIdentifiers = productIdentifiers
        
        for productIdentifier in productIdentifiers {
            let purchased = NSUserDefaults.standardUserDefaults().boolForKey(productIdentifier)
            if purchased {
                purchasedProductIdentifiers.insert(productIdentifier)
            } else {
                print("Not Purchased: \(productIdentifier)")
            }
        }
        super.init()
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
    }
    
    public func requestProductsWithCompletionHandler(handler: RequestProductsCompletionHandler) {
        completionHandler = handler
        
//        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productsRequest = SKProductsRequest(productIdentifiers: Set(productIdentifiers))
        productsRequest?.delegate = self
        productsRequest?.start()
    }
  
    public func isProductPurchased(productIdentifer: ProductIdentifier) -> Bool {
        return purchasedProductIdentifiers.contains(productIdentifer)
    }
    public func restoreCompletedTransaction() {
        SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
    }
    public class func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
    public func checkPaymentStatus() {
        let store = IAPHelper(productIdentifiers: productIdentifiers)
        if store.isProductPurchased("com.TetherLocate.Tether.InAppPurchases") {
            
        }
    }
}
extension IAPHelper: SKProductsRequestDelegate {
    public func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        print("Loaded list of products...")
        
//        let products = response.products as! [SKProduct]
        let products = response.products
        completionHandler?(success: true, products: products)
        clearRequest()

        for p in products {
            print("Found products: \(p.productIdentifier) \(p.localizedTitle)")
        }
    }
    public func request(request: SKRequest, didFailWithError error: NSError) {
        print("Failed to load list of products.")
        print("Error: \(error)")
        clearRequest()
    }
    private func clearRequest() {
        productsRequest = nil
        completionHandler = nil
    }
}
extension IAPHelper: SKPaymentTransactionObserver {
    public func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch (transaction.transactionState) {
            case .Purchased:
                completeTransaction(transaction)
                break
            case .Failed:
                failedTransaction(transaction)
                break
            case .Restored:
                restoreTransaction(transaction)
                break
            case .Deferred:
                break
            case .Purchasing:
                break
            }
        }
    }
    private func completeTransaction(transaction: SKPaymentTransaction) {
        print("completeTransaction...")
        provideFunctionalityForProductIdentifier(transaction.payment.productIdentifier)
        SKPaymentQueue.defaultQueue().finishTransaction(transaction)
    }
    private func restoreTransaction(transaction: SKPaymentTransaction) {
        let productIdentifier = transaction.originalTransaction!.payment.productIdentifier
        print("restoreTransaction... \(productIdentifier)")
        provideFunctionalityForProductIdentifier(productIdentifier)
        SKPaymentQueue.defaultQueue().finishTransaction(transaction)
    }
    private func provideFunctionalityForProductIdentifier(productIdentifier: String) {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: productIdentifier)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    private func failedTransaction(transaction: SKPaymentTransaction) {
        print("failedTransaction...")
        if transaction.error! != SKErrorCode.PaymentCancelled.rawValue {
            print("Transaction error: \(transaction.error!.localizedDescription)")
        }
        SKPaymentQueue.defaultQueue().finishTransaction(transaction)
    }
}





