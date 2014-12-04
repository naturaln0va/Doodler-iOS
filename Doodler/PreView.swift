//
//  PreView.swift
//  DrawingApp
//
//  Created by Ryan Ackermann on 11/7/14.
//  Copyright (c) 2014 Ryan Ackermann. All rights reserved.
//

import UIKit

class PreView: UIView {
    
    var lineWidth: CGFloat = 10.0
    var drawColor: UIColor = UIColor.blackColor()

    override func drawRect(rect: CGRect) {
        var context = UIGraphicsGetCurrentContext()
        CGContextSetLineJoin(context, kCGLineJoinRound)
        CGContextSetLineCap(context, kCGLineCapRound)
        CGContextBeginPath(context)
        CGContextMoveToPoint(context, CGRectGetMidX(self.bounds), CGRectGetMinY(self.bounds))
        CGContextAddLineToPoint(context, CGRectGetMidX(self.bounds), CGRectGetMaxY(self.bounds))
        CGContextSetStrokeColorWithColor(context, drawColor.CGColor)
        CGContextSetLineWidth(context, lineWidth)
        CGContextStrokePath(context)
    }

}
