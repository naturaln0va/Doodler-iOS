//
//  Created by Ryan Ackermann on 7/17/15.
//  Copyright (c) 2015 Ryan Ackermann. All rights reserved.
//

import UIKit

class ColorPreviewButton: UIView
{
    var color: UIColor?
    {
        didSet {
            if self.color!.isDarkColor() {
                self.layer.borderColor = UIColor.whiteColor().CGColor
                self.layer.borderWidth = 1
                self.layer.cornerRadius = CGRectGetWidth(bounds) / 2
            } else {
                self.layer.borderColor = UIColor.clearColor().CGColor
                self.layer.borderWidth = 0
                self.layer.cornerRadius = CGRectGetWidth(bounds) / 2
            }
            setNeedsDisplay()
        }
    }
    
    override func drawRect(rect: CGRect)
    {
        let ctx = UIGraphicsGetCurrentContext()
        UIColor(hex: 0x191919).set()
        UIRectFill(rect)
        
        color?.set()
        CGContextFillEllipseInRect(ctx, rect)
    }
}
