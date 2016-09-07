//
//  AppearanceController.swift
//  Tether
//
//  Created by Zach Steed on 1/13/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//
import Foundation
import UIKit

class AppearanceController {
    
    class func setUpAppearance() {
        UINavigationBar.appearance().barTintColor = UIColor.darkerGrayColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        UIBarButtonItem.appearance().tintColor = UIColor.turquoiseColor()
        UITableView.appearance().backgroundColor = UIColor.darkerGrayColor()
        UITableViewCell.appearance().backgroundColor = UIColor.darkerGrayColor()
        UISearchBar.appearance().barTintColor = UIColor.darkerGrayColor()

    }
}

extension UIColor {
    
    class func darkerGrayColor() -> UIColor {
        return UIColor(red: 47/255, green: 47/255, blue: 47/255, alpha: 1.0)
    }
    
    class func lighterGrayColor() ->UIColor {
        return UIColor(red: 166/255, green: 166/255, blue: 165/255, alpha: 1.0)
    }
    class func turquoiseColor() -> UIColor{

        return UIColor(red: 26/255, green: 144/255, blue: 144/255, alpha: 1.0)
    }
    
    class func redRejectColor() -> UIColor {
        return UIColor(red: 240/255, green: 70/255, blue: 43/255, alpha: 1.0)
    }
}