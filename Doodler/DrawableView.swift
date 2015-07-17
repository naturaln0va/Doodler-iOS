//
//  Created by Ryan Ackermann on 7/7/15.
//  Copyright (c) 2015 Ryan Ackermann. All rights reserved.
//

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
    private var bufferImage: UIImage?
    
    //MARK: - Public API -
    func clear()
    {
        drawingComponents.removeAll(keepCapacity: false)
        bufferImage = nil
        setNeedsDisplay()
    }
    
    func setupAndDrawWithPoints(#points: [CGPoint], withColor color: CGColorRef, withWidth width: CGFloat)
    {
        let mid1 = midPoint(points[1], point2: points[2])
        let mid2 = midPoint(points[0], point2: points[1])
        
        let subPath = CGPathCreateMutable()
        CGPathMoveToPoint(subPath, nil, mid1.x, mid1.y)
        CGPathAddQuadCurveToPoint(subPath, nil, points[1].x, points[1].y, mid2.x, mid2.y)
        
        let bounds = CGPathGetBoundingBox(subPath)
        let drawBounds = CGRectInset(bounds, -5.0 * width, -5.0 * width)
        
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
        bufferImage = self.imageByCapturing()
        drawingComponents.removeAll(keepCapacity: false)
        setNeedsDisplay()
    }
    
    //MARK - UIView Lifecycle -
    override func drawRect(rect: CGRect)
    {
        let ctx = UIGraphicsGetCurrentContext()
        CGContextSetLineCap(ctx, kCGLineCapRound)
        
        CGContextSetFillColorWithColor(ctx, UIColor.whiteColor().CGColor)
        UIRectFill(rect)
        
        if let img = bufferImage {
            img.drawAtPoint(CGPointZero)
        }
        
        for comp in drawingComponents {
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
            return
        }
        
        let touch = touches.first as! UITouch
        
        previousPoint = touch.previousLocationInView(self)
        previousPreviousPoint = touch.previousLocationInView(self)
        currentPoint = touch.locationInView(self)
        
        touchesMoved(touches, withEvent: event)
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent)
    {
        if event.allTouches()?.count > 1 {
            return
        }
        
        let touch = touches.first as! UITouch
        let point = touch.locationInView(self)
        
        let dx = point.x - currentPoint!.x
        let dy = point.y - currentPoint!.y
        
        if (dx * dx + dy * dy) < 25 {
            return
        }
        
        previousPreviousPoint = previousPoint
        previousPoint = touch.previousLocationInView(self)
        currentPoint = touch.locationInView(self)
        
        let drawColor = SettingsController.sharedController.currentStrokeColor().CGColor
        let drawWidth = CGFloat(SettingsController.sharedController.currentStrokeWidth())
        let points = [currentPoint!, previousPoint!, previousPreviousPoint!]
        
        setupAndDrawWithPoints(points: points, withColor: drawColor, withWidth: drawWidth)
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent)
    {
        let drawColor = SettingsController.sharedController.currentStrokeColor().CGColor
        let drawWidth = CGFloat(SettingsController.sharedController.currentStrokeWidth())
        let points = [currentPoint!, previousPoint!, previousPreviousPoint!]
        
        setupAndDrawWithPoints(points: points, withColor: drawColor, withWidth: drawWidth)
        
        renderDisplayToBuffer()
    }
    
    override func touchesCancelled(touches: Set<NSObject>!, withEvent event: UIEvent!)
    {
        currentPoint = nil
        previousPoint = nil
        previousPreviousPoint = nil
    }
}
