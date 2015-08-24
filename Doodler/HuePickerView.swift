//
//  HuePickerView.swift
//
//  Created by Ryan Ackermann on 8/13/15.
//  Copyright (c) 2015 Ryan Ackermann. All rights reserved.
//  Find me on Twitter @naturaln0va.
//  Under The MIT License (MIT). See license.txt for more info.

import UIKit

protocol HuePickerViewDelegate
{
    func huePickerViewDidUpdateHue(hue: CGFloat)
}

class HuePickerView: UIView
{
    
    private let step: CGFloat = 0.166666666666667
    private let hueIndicatorSize: CGFloat = 5
    var delegate: HuePickerViewDelegate?
    
    var hue: CGFloat = 0.5 {
        didSet {
            delegate?.huePickerViewDidUpdateHue(self.hue)
            setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    private func commonInit()
    {
        clipsToBounds = true
    }

    override func drawRect(rect: CGRect)
    {
        let ctx = UIGraphicsGetCurrentContext()
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let locations = [CGFloat(0.0), step, step * 2, step * 3, step * 4, step * 5, CGFloat(1.0)]
        
        let colors = [
            UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0).CGColor,
            UIColor(red: 1.0, green: 0.0, blue: 1.0, alpha: 1.0).CGColor,
            UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0).CGColor,
            UIColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0).CGColor,
            UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0).CGColor,
            UIColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0).CGColor,
            UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0).CGColor
        ]
        
        let gradient = CGGradientCreateWithColors(colorSpace, colors, locations)
        CGContextDrawLinearGradient(ctx, gradient, CGPoint(x: CGRectGetWidth(rect), y: 0), CGPointZero, 0)
        
        let adjustedPosition = CGFloat(CGRectGetWidth(rect)) * hue
        
        CGContextAddRect(ctx, CGRect(x: adjustedPosition - (hueIndicatorSize / 2), y: 0, width: hueIndicatorSize, height: CGRectGetHeight(rect)))
        CGContextSetFillColorWithColor(ctx, UIColor.whiteColor().CGColor)
        CGContextSetShadowWithColor(ctx, CGSizeZero, 2, UIColor.blackColor().CGColor)
        CGContextClosePath(ctx)
        CGContextDrawPath(ctx, kCGPathFill)
    }
    
    //MARK: - Touches -
    private func handleTouches(touches: Set<NSObject>)
    {
        let touch = touches.first as! UITouch
        let point = touch.locationInView(self)
        
        if point.x < 0 {
            hue = 0
        }
        else if point.x > CGRectGetWidth(bounds) {
            hue = 1
        }
        else {
            hue = point.x / CGRectGetWidth(bounds)
        }
        
        setNeedsDisplay()
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent)
    {
        handleTouches(touches)
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent)
    {
        handleTouches(touches)
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent)
    {
        handleTouches(touches)
    }

}
