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
    var moving: Bool = false
    var eraserEnabled: Bool = false
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
        
        drawableSize = CGSize(width: self.frame.size.width * contentScaleFactor, height: self.frame.size.height * contentScaleFactor)
        self.addSubview(bufferImageView)
        
        layer.magnificationFilter = kCAFilterNearest
        layer.shouldRasterize = true
    }
    
    func setUpAndDraw(width: Float, color: UIColor, lastX: CGFloat, lastY: CGFloat, x: CGFloat, y: CGFloat) {
        UIGraphicsBeginImageContext(drawableSize)
        var ctx = UIGraphicsGetCurrentContext()
        bufferImageView.image?.drawInRect(CGRect(origin: CGPoint(x: 0, y: 0), size: drawableSize))
        CGContextMoveToPoint(ctx, lastX, lastY)
        CGContextAddLineToPoint(ctx, x, y)
        CGContextSetLineJoin(ctx, kCGLineJoinRound)
        CGContextSetLineCap(ctx, kCGLineCapRound)
        if eraserEnabled {
            CGContextSetStrokeColorWithColor(ctx, UIColor.whiteColor().CGColor)
        } else {
            CGContextSetStrokeColorWithColor(ctx, color.CGColor)
        }
        CGContextSetLineWidth(ctx, CGFloat(width))
        CGContextSetBlendMode(ctx, kCGBlendModeNormal)
        CGContextSetShouldAntialias(ctx, true)
        CGContextSetInterpolationQuality(ctx, kCGInterpolationHigh)
        CGContextStrokePath(ctx)
        if !moving {
            CGContextFlush(ctx)
        }
        bufferImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if event.allTouches()?.count > 1 {
            return
        }
        
        moving = false
        
        let touch = touches.first as! UITouch
        let location = touch.locationInView(self)
        lastPoint = CGPoint(x: location.x * 2, y: location.y * 2)
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        if event.allTouches()?.count > 1 {
            return
        }
        
        moving = true
        let touch = touches.first as! UITouch
        let location = touch.locationInView(self)
        newPoint = CGPoint(x: location.x * 2, y: location.y * 2)
        //notificationCenter.postNotificationName("NOTIFICATION_LINE_TO_SEND", object: self)
        var colorForDrawing = SettingsController.sharedController.currentStrokeColor()
        var widthForDrawing = SettingsController.sharedController.currentStrokeWidth()
        
        setUpAndDraw(widthForDrawing, color: colorForDrawing, lastX: lastPoint.x, lastY: lastPoint.y, x: newPoint.x, y: newPoint.y)
        lastPoint = newPoint
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        if event.allTouches()?.count > 1 {
            return
        }
        
        //notificationCenter.postNotificationName("NOTIFICATION_LINE_TO_SEND", object: self)
        var colorForDrawing = SettingsController.sharedController.currentStrokeColor()
        var widthForDrawing = SettingsController.sharedController.currentStrokeWidth()
        
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
