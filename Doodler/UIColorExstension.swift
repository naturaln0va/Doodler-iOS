//
//  Created by Ryan Ackermann on 6/13/15.
//  Copyright (c) 2015 Ryan Ackermann. All rights reserved.
//

import UIKit

extension UIColor
{
    
    convenience init(hex: Int)
    {
        let red = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hex & 0xFF00) >> 8) / 255.0
        let blue = CGFloat(hex & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: 1.0);
    }
    
    func hexString() -> String?
    {
        var redValue: CGFloat = 0
        var greenValue: CGFloat = 0
        var blueValue: CGFloat = 0
        var alphaValue: CGFloat = 0
        
        if self.getRed(&redValue, green: &greenValue, blue: &blueValue, alpha: &alphaValue) {
            
            let r = Int(redValue * 255.0)
            let g = Int(greenValue * 255.0)
            let b = Int(blueValue * 255.0)
            
            return "#"+String(format: "%02X", Int(r))+String(format: "%02X", Int(g))+String(format: "%02X", Int(b))
        } else {
            return nil
        }
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
    
    func red() -> CGFloat
    {
        let comps = CGColorGetComponents(CGColor)
        return comps[0]
    }
    
    func green() -> CGFloat
    {
        let comps = CGColorGetComponents(CGColor)
        return comps[1]
    }
    
    func blue() -> CGFloat
    {
        let comps = CGColorGetComponents(CGColor)
        return comps[2]
    }
    
    func isDarkColor() -> Bool
    {
        let brightnessThreshold: Float = 125
        let colorThreshold: Float = 500
        
        let fr = 255
        let fg = 255
        let fb = 255
        
        let br = Int(red() * 255)
        let bg = Int(green() * 255)
        let bb = Int(blue() * 255)
        
        let by = Float((br * 299) + (bg * 587) + (bb * 114)) / 1000
        let fy = Float((255 * 299) + (255 * 587) + (255 * 114)) / 1000
        let brightnessDifference = fabs(by - fy)
        
        let colorDifference = Float((max(fr, br) - min(fr, br)) + (max(fg, bg) - min(fg, bg)) + (max(fb, bb) - min(fb, bb)))
        
        return brightnessDifference >= brightnessThreshold || colorDifference >= colorThreshold
    }
    
}