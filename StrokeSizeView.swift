//
//  Created by Ryan Ackermann on 8/23/15.
//  Copyright (c) 2015 Ryan Ackermann. All rights reserved.
//

import UIKit

class StrokeSizeView: AutoHideView {

    var strokeSize: CGFloat? {
        didSet {
            setNeedsDisplay()
            show()
        }
    }
    
    override func show()
    {
        UIView.animateWithDuration(animationDuration) {
            self.alpha = 0.675
        }
        
        if let t = timer {
            if t.valid {
                self.timer?.invalidate()
            }
        }
        
        timer = NSTimer.scheduledTimerWithTimeInterval(animationDuration * 2, target: self, selector: "hide", userInfo: nil, repeats: false)
    }
    
    override func drawRect(rect: CGRect)
    {
        let ctx = UIGraphicsGetCurrentContext()
        
        // Drawing code
        UIColor(hex: 0x262626).set()
        UIRectFill(rect)
        
        if let size = strokeSize {
            CGContextSetLineCap(ctx, kCGLineCapRound)
            CGContextSetStrokeColorWithColor(ctx, UIColor.whiteColor().CGColor)
            CGContextSetLineWidth(ctx, size)
            
            let path = CGPathCreateMutable()
            let xPos = CGRectGetMidX(rect)
            let yPos = CGRectGetMidY(rect)
            CGPathMoveToPoint(path, nil, xPos, yPos)
            CGPathAddLineToPoint(path, nil, xPos, yPos)
            
            CGContextAddPath(ctx, path)
            CGContextStrokePath(ctx)
        }
    }
}
