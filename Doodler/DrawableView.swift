//  Created by Ryan Ackermann on 7/7/15.
//  Copyright (c) 2015 Ryan Ackermann. All rights reserved.
//  Find me on Twitter @naturaln0va.
//  Under The MIT License (MIT). See license.txt for more info.

import UIKit

struct DrawComponent
{
    var path: CGMutablePathRef
    var width: CGFloat
    var color: CGColorRef
}

class DrawableView: UIView
{
    //MARK: - Private Variables -
    private var currentPoint: CGPoint?
    private var previousPoint: CGPoint?
    private var previousPreviousPoint: CGPoint?
    
    private var drawingComponents = [DrawComponent]()
    
    private var bufferImage: UIImage? {
        didSet {
            drawingComponents.removeAll(keepCapacity: false)
        }
    }
    
    //MARK: - Public API -
    func clear()
    {
        bufferImage = nil
        setNeedsDisplay()
        CacheController.sharedController.addItem(imageByCapturing())
    }
    
    func undo()
    {        
        if let image = CacheController.sharedController.lastAddedImage() {
            self.bufferImage = image
            setNeedsDisplay()
        }
        else {
            bufferImage = nil
            setNeedsDisplay()
        }
    }
    
    func setupAndDrawWithPoints(#points: [CGPoint], withColor color: CGColorRef, withWidth width: CGFloat)
    {
        let mid1 = midPoint(points[1], point2: points[2])
        let mid2 = midPoint(points[0], point2: points[1])
        
        let subPath = CGPathCreateMutable()
        CGPathMoveToPoint(subPath, nil, mid1.x, mid1.y)
        CGPathAddQuadCurveToPoint(subPath, nil, points[1].x, points[1].y, mid2.x, mid2.y)
        
        let boxOffset = CGFloat(SettingsController.sharedController.currentStrokeWidth())
        let drawBounds = CGRectInset(CGPathGetBoundingBox(subPath), -boxOffset, -boxOffset)
        
        drawingComponents.append(DrawComponent(path: subPath, width: width, color: color))
        
        setNeedsDisplayInRect(drawBounds)
    }
    
    //MARK: - Private API -
    private func midPoint(point1: CGPoint, point2: CGPoint) -> CGPoint
    {
        return CGPoint(x: (point1.x + point2.x) * 0.5, y: (point1.y + point2.y) * 0.5)
    }
    
    private func renderDisplayToBuffer()
    {
        let dispatchQueue = isIOS8OrLater() ? dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0) : dispatch_queue_create("background-queue-worker", DISPATCH_QUEUE_PRIORITY_BACKGROUND)
        dispatch_async(dispatchQueue) {
            let image = self.imageByCapturing()
            self.bufferImage = image
            CacheController.sharedController.addItem(image)
        }
    }
    
    //MARK - UIView Lifecycle -
    override func drawRect(rect: CGRect)
    {
        let ctx = UIGraphicsGetCurrentContext()
        
        if ctx == nil {
            return
        }
        
        UIColor.whiteColor().setFill()
        UIRectFill(rect)
        
        if let img = bufferImage {
            img.drawAtPoint(CGPointZero)
        }
        
        for comp in drawingComponents {
            CGContextSetLineCap(ctx, kCGLineCapRound)
            CGContextSetStrokeColorWithColor(ctx, comp.color)
            CGContextSetLineWidth(ctx, comp.width)
            
            CGContextAddPath(ctx, comp.path)
            CGContextStrokePath(ctx)
        }
    }
    
    //MARK: - UITouch Event Handling -
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent)
    {
        if event.allTouches()?.count > 1 {
            return // We only want to deal with one touch
        }
        
        let touch = touches.first as! UITouch
        
        previousPoint = touch.previousLocationInView(self)
        previousPreviousPoint = touch.previousLocationInView(self)
        currentPoint = touch.locationInView(self)
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent)
    {
        if event.allTouches()?.count > 1 {
            return // We only want to deal with one touch
        }
        
        let touch = touches.first as! UITouch
        let point = touch.locationInView(self)
        
        let dx = point.x - currentPoint!.x
        let dy = point.y - currentPoint!.y
        
        if (dx * dx + dy * dy) < CGFloat(SettingsController.sharedController.currentStrokeWidth()) {
            return
        }
        
        previousPreviousPoint = previousPoint
        previousPoint = touch.previousLocationInView(self)
        currentPoint = touch.locationInView(self)
        
        let drawColor = SettingsController.sharedController.currentDrawColor().CGColor
        let drawWidth = CGFloat(SettingsController.sharedController.currentStrokeWidth())
        let points = [currentPoint!, previousPoint!, previousPreviousPoint!]
        
        setupAndDrawWithPoints(points: points, withColor: drawColor, withWidth: drawWidth)
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent)
    {
        if event.allTouches()?.count > 1 {
            return // We only want to deal with one touch
        }
        
        let drawColor = SettingsController.sharedController.currentDrawColor().CGColor
        let drawWidth = CGFloat(SettingsController.sharedController.currentStrokeWidth())
        let points = [currentPoint!, previousPoint!, previousPreviousPoint!]
        
        setupAndDrawWithPoints(points: points, withColor: drawColor, withWidth: drawWidth)
        
        renderDisplayToBuffer()
    }
    
}
