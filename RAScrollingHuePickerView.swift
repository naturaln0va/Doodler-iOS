//
//  Created by Ryan Ackermann on 7/8/15.
//  Copyright (c) 2015 Ryan Ackermann. All rights reserved.
//

import UIKit

class RAScrollingHuePickerView: UIView
{
    private var value: CGFloat {
        get {
            return self.value
        }
        set {
            self.value = newValue
            setNeedsDisplay()
        }
    }
    
    private let colors =
    [
        UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0).CGColor,   // Red
        UIColor(red: 1.0, green: 0.0, blue: 1.0, alpha: 1.0).CGColor,   // Magenta
        UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0).CGColor,   // Blue
        UIColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0).CGColor,   // Cyan
        UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0).CGColor,   // Green
        UIColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0).CGColor,   // Yellow
        UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0).CGColor    // Red
    ]
    
    private func locations(#steps: Int) -> [CGFloat]
    {
        var result = [CGFloat]()
        let step = CGFloat(1) / CGFloat(steps)
        
        for i in 0..<(steps - 1) {
            result.append(step * CGFloat(i))
        }
        
        result.append(1.0)
        
        return result
    }
    
    override func drawRect(rect: CGRect)
    {
        let ctx = UIGraphicsGetCurrentContext()
        
        let gradient = CGGradientCreateWithColors(CGColorSpaceCreateDeviceRGB(), [colors[1], colors[2], colors[3]], locations(steps: 3))
        
        CGContextDrawLinearGradient(ctx, gradient, CGPoint(x: rect.size.width, y: 0), CGPointZero, 0)
        
        let selectionPath = CGPathCreateMutable()
        let verticalPadding = CGRectGetHeight(rect) * 0.4
        let horizontalPosition = CGRectGetMidX(rect)
        
        CGPathMoveToPoint(selectionPath, nil, horizontalPosition, verticalPadding * 0.5)
        CGPathAddLineToPoint(selectionPath, nil, horizontalPosition, CGRectGetHeight(rect) - (verticalPadding * 0.5))
        
        CGContextAddPath(ctx, selectionPath)
        
        CGContextSetLineWidth(ctx, 1.0)
        CGContextSetStrokeColorWithColor(ctx, UIColor.blackColor().CGColor)
        
        CGContextStrokePath(ctx)
    }
}
