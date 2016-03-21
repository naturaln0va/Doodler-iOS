//
//  Created by Ryan Ackermann on 7/17/15.
//  Copyright (c) 2015 Ryan Ackermann. All rights reserved.
//

import UIKit

class ColorPreView: UIView
{
    var previousColor: UIColor? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var newColor: UIColor? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func drawRect(rect: CGRect)
    {
        let ctx = UIGraphicsGetCurrentContext()
        
        let clippingPath = UIBezierPath(roundedRect: rect, cornerRadius: 5).CGPath
        CGContextAddPath(ctx, clippingPath)
        
        CGContextClip(ctx)
        
        if let previous = previousColor {
            previous.set()
            CGContextFillRect(ctx, CGRect(x: 0, y: 0, width: rect.width / 2, height: rect.height))
        }
        
        if let new = newColor {
            new.set()
            CGContextFillRect(ctx, CGRect(x: rect.width / 2, y: 0, width: rect.width / 2, height: rect.height))
        }
    }
}
