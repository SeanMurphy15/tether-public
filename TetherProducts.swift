//
//  TetherProducts.swift
//  Tether
//
//  Created by JB on 1/15/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation

public enum TetherProducts {

    /// TODO:  Change this to whatever you set on iTunes connect
    static let tetherPremiumID = "com.TetherLocate.Tether.InAppPurchases"

    /// MARK: - Supported Product Identifiers

    // All of the products assembled into a set of product identifiers.
    private static let productIdentifiers: Set<ProductIdentifier> = [tetherPremiumID]

    /// Static instance of IAPHelper that for rage products.
    public static let store = IAPHelper(productIdentifiers: TetherProducts.productIdentifiers)
}

/// Return the resourcename for the product identifier.
func resourceNameForProductIdentifier(productIdentifier: String) -> String? {
    return productIdentifier.componentsSeparatedByString(".").last
}