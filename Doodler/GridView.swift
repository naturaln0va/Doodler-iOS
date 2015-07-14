//
//  Created by Ryan Ackermann on 7/1/15.
//  Copyright (c) 2015 Ryan Ackermann. All rights reserved.
//

import UIKit

class GridView: UIView
{

    override func drawRect(rect: CGRect)
    {
        let width: CGFloat = CGRectGetWidth(bounds)
        let height: CGFloat = CGRectGetHeight(bounds)
        let spaceBetween: CGFloat = 18.0
        let ctx: CGContextRef = UIGraphicsGetCurrentContext()
        
        CGContextSetLineWidth(ctx, 1.0)
        CGContextSetStrokeColorWithColor(ctx, UIColor(white: 1.0, alpha: 0.075).CGColor)
        CGContextSetFillColorWithColor(ctx, UIColor(white: 0.15, alpha: 1.0).CGColor)
        
        CGContextFillRect(ctx, bounds)
        
        for var x: CGFloat = 0; x < width; x += spaceBetween {
            for var y: CGFloat = 0; y < height; y += spaceBetween {
                CGContextMoveToPoint(ctx, x, y)
                CGContextAddLineToPoint(ctx, max(x + width, width) , y)
                
                CGContextMoveToPoint(ctx, x, y)
                CGContextAddLineToPoint(ctx, x, max(y + height, height))
            }
        }
        
        CGContextStrokePath(ctx)
    }
    
}
