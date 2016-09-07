//
//  Swift Extensions.swift
//  Tether
//
//  Created by Zach Steed on 1/7/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import UIKit

extension String {
    func contains(stuff: [String]) -> Bool {
        var doesContain = false
        for string in stuff {
            if self.rangeOfString(string) != nil {
                doesContain = true
            }
        }
        return doesContain
    }
}
