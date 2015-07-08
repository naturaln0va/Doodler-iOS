//
//  Created by Ryan Ackermann on 6/13/15.
//  Copyright (c) 2015 Ryan Ackermann. All rights reserved.
//

import UIKit

extension UIColor
{
    convenience init(hex: Int, alpha: CGFloat = 1.0)
    {
        let red = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hex & 0xFF00) >> 8) / 255.0
        let blue = CGFloat(hex & 0xFF) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha);
    }
    
    func componentToHex(component: Int) -> String
    {
        if component == 0 {
            return "00"
        } else {
            return NSString(format: "%02X", component) as String
        }
    }
    
    func rgbToHex(r: String, g: String, b: String) -> Int
    {
        let charArray = "0x\(r)\(g)\(b)"
        return Int(strtol(charArray, nil, 0))
    }

    func rgb() -> Array<Float>?
    {
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            
            return [Float(fRed), Float(fGreen), Float(fBlue)]
        } else {
            return nil
        }
    }
    
}