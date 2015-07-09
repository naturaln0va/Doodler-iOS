//
//  Created by Ryan Ackermann on 7/8/15.
//  Copyright (c) 2015 Ryan Ackermann. All rights reserved.
//

import UIKit

class RAScrollingHuePickerView: UIView
{
    override func drawRect(rect: CGRect)
    {
        // Context for drawing
        let ctx = UIGraphicsGetCurrentContext()
        
        // Define a color space
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        // Define a step for the hue
        let step = CGFloat(0.166666666666667)
        
        // Define an array of the color step locations
        let locations = [0.0, step, step * 2, step * 3, step * 4, step * 5, 1.0]
        
        // Define an 
        let colors = [UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0).CGColor,     // Red
                        UIColor(red: 1.0, green: 0.0, blue: 1.0, alpha: 1.0).CGColor,   // Magenta
                        UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0).CGColor,   // Blue
                        UIColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0).CGColor,   // Cyan
                        UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0).CGColor,   // Green
                        UIColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0).CGColor,   // Yellow
                        UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0).CGColor    // Red
                     ]
        
        let gradient = CGGradientCreateWithColors(colorSpace, colors, locations)
        
        CGContextDrawLinearGradient(ctx, gradient, CGPoint(x: rect.size.width, y: 0), CGPointZero, 0)
    }
}
