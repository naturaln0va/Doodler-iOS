//
//  Created by Ryan Ackermann on 7/7/15.
//  Copyright (c) 2015 Ryan Ackermann. All rights reserved.
//

import UIKit

class DrawableView: UIView
{
    //MARK: - Public Variables -
    var lineWidth: CGFloat = CGFloat(10.0)
    var lineColor: UIColor = UIColor.blackColor()

    //MARK: - Private Variables -
    private var currentPoint: CGPoint?
    private var previousPoint: CGPoint?
    private var previousPreviousPoint: CGPoint?
    
    private var path: CGMutablePathRef = CGPathCreateMutable()
    
    //MARK: - Public API -
    func clear()
    {
        path = CGPathCreateMutable()
        setNeedsDisplay()
    }
    
    //MARK: - Private API -
    private func midPoint(point1: CGPoint, point2: CGPoint) -> CGPoint
    {
        return CGPoint(x: (point1.x + point2.x) * 0.5, y: (point1.y + point2.y) * 0.5)
    }
    
    //MARK - UIView Lifecycle -
    override func drawRect(rect: CGRect)
    {
        UIColor.whiteColor().set()
        UIRectFill(rect)
        
        let ctx = UIGraphicsGetCurrentContext()
        
        CGContextAddPath(ctx, path)
        CGContextSetLineCap(ctx, kCGLineCapRound)
        CGContextSetLineWidth(ctx, CGFloat(SettingsController.sharedController.currentStrokeWidth()))
        CGContextSetStrokeColorWithColor(ctx, SettingsController.sharedController.currentStrokeColor().CGColor)
        
        CGContextStrokePath(ctx)
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
        
        let mid1 = midPoint(previousPoint!, point2: previousPreviousPoint!)
        let mid2 = midPoint(currentPoint!, point2: previousPoint!)
        
        let subPath = CGPathCreateMutable()
        CGPathMoveToPoint(subPath, nil, mid1.x, mid1.y)
        CGPathAddQuadCurveToPoint(subPath, nil, previousPoint!.x, previousPoint!.y, mid2.x, mid2.y)
        
        let bounds = CGPathGetBoundingBox(subPath)
        let drawBounds = CGRectInset(bounds, -2.0 * lineWidth, -2.0 * lineWidth)
        
        CGPathAddPath(path, nil, subPath)
        setNeedsDisplayInRect(drawBounds)
    }
}
