//
//  DrawView.swift
//  DrawingApp
//
//  Created by Ryan Ackermann on 11/6/14.
//  Copyright (c) 2014 Ryan Ackermann. All rights reserved.
//

import UIKit

class DrawView: UIImageView {
    
    var lastPoint: CGPoint!
    var newPoint: CGPoint!
    var opacityForBuffer: CGFloat!
    var moving: Bool = false
    var lineWidth: CGFloat = 10.0
    var bufferImageView: UIImageView!
    let notificationCenter = NSNotificationCenter.defaultCenter()
    let defaults = NSUserDefaults.standardUserDefaults()
    var drawableSize: CGSize!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        bufferImageView = UIImageView(frame: self.bounds)
        self.contentScaleFactor = 2.0
        bufferImageView.contentScaleFactor = 2.0
        self.contentMode = UIViewContentMode.ScaleAspectFit
        bufferImageView.contentMode = self.contentMode
        opacityForBuffer = 1.0
        
        drawableSize = CGSize(width: self.frame.size.width * contentScaleFactor, height: self.frame.size.height * contentScaleFactor)
        
        self.addSubview(bufferImageView)
    }
    
    func setUpAndDraw(width: CGFloat, color: UIColor, lastX: CGFloat, lastY: CGFloat, x: CGFloat, y: CGFloat) {
        UIGraphicsBeginImageContext(drawableSize)
        var context = UIGraphicsGetCurrentContext()
        bufferImageView.image?.drawInRect(CGRect(origin: CGPoint(x: 0, y: 0), size: drawableSize))
        CGContextMoveToPoint(context, lastX, lastY)
        CGContextAddLineToPoint(context, x, y)
        CGContextSetLineJoin(context, kCGLineJoinRound)
        CGContextSetShouldAntialias(context, true)
        CGContextSetLineCap(context, kCGLineCapRound)
        CGContextSetStrokeColorWithColor(context, color.CGColor)
        CGContextSetLineWidth(context, width)
        CGContextSetBlendMode(context, kCGBlendModeNormal)
        CGContextSetShouldAntialias(context, true)
        CGContextSetInterpolationQuality(context, kCGInterpolationHigh)
        CGContextStrokePath(context)
        if !moving {
            CGContextFlush(context)
        }
        bufferImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        bufferImageView.alpha = opacityForBuffer
        UIGraphicsEndImageContext()
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        moving = false
        
        let touchPoint = touches.anyObject()!.locationInView(self)
        lastPoint = CGPoint(x: touchPoint.x * 2, y: touchPoint.y * 2)
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        moving = true
        let touchPoint = touches.anyObject()!.locationInView(self)
        newPoint = CGPoint(x: touchPoint.x * 2, y: touchPoint.y * 2)
        notificationCenter.postNotificationName("NOTIFICATION_LINE_TO_SEND", object: self)
        var colorForDrawing = UIColor(hex: defaults.objectForKey("color") as Int)
        var widthForDrawing = defaults.objectForKey("lineWidth") as CGFloat
        
        setUpAndDraw(widthForDrawing, color: colorForDrawing, lastX: lastPoint.x, lastY: lastPoint.y, x: newPoint.x, y: newPoint.y)
        
        lastPoint = newPoint
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        notificationCenter.postNotificationName("NOTIFICATION_LINE_TO_SEND", object: self)
        var colorForDrawing = UIColor(hex: defaults.objectForKey("color") as Int)
        var widthForDrawing = defaults.objectForKey("lineWidth") as CGFloat
        
        if !moving {
            setUpAndDraw(widthForDrawing, color: colorForDrawing, lastX: lastPoint.x, lastY: lastPoint.y, x: lastPoint.x, y: lastPoint.y)
        }
        
        UIGraphicsBeginImageContext(drawableSize)
        self.image?.drawInRect(CGRect(origin: CGPoint(x: 0, y: 0), size: drawableSize), blendMode: kCGBlendModeNormal, alpha: 1.0)
        bufferImageView.image?.drawInRect(CGRect(origin: CGPoint(x: 0, y: 0), size: drawableSize), blendMode: kCGBlendModeNormal, alpha: 1.0)
        self.image = UIGraphicsGetImageFromCurrentImageContext()
        bufferImageView.image = nil
        UIGraphicsEndImageContext()
    }

}
