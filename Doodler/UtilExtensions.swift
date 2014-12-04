//
//  UtilExtensions.swift
//
//  All Purpose Extensions for a Swift Project
//
//  Created by Ryan Ackermann on 10/20/14.
//  Copyright (c) 2014 Ryan Ackermann. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let red = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hex & 0xFF00) >> 8) / 255.0
        let blue = CGFloat(hex & 0xFF) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha);
    }
    
    func componentToHex(component: Int) -> String {
        if component == 0 {
            return "00"
        } else {
            return NSString(format: "%2X", component)
        }
    }
    
    func rgbToHex(r: String, g: String, b: String) -> Int {
        let charArray = "0x\(r)\(g)\(b)"
        return Int(strtol(charArray, nil, 0))
    }
}
