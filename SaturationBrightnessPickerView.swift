//
//  SaturationBrightnessPickerView.swift
//
//  Created by Ryan Ackermann on 8/13/15.
//  Copyright (c) 2015 Ryan Ackermann. All rights reserved.
//  Find me on Twitter @naturaln0va.
//  Under The MIT License (MIT). See license.txt for more info.

import UIKit

protocol SaturationBrightnessPickerViewDelegate
{
    func saturationBrightnessPickerViewDidUpdateColor(color: UIColor)
}

class SaturationBrightnessPickerView: UIView, HuePickerViewDelegate
{
    
    private let inset: CGFloat = 15
    private let reticuleSize: CGFloat = 25
    var delegate: SaturationBrightnessPickerViewDelegate?
    
    var hue: CGFloat = 1.0 {
        didSet {
            delegate?.saturationBrightnessPickerViewDidUpdateColor(currentColor())
            setNeedsDisplay()
        }
    }
    
    private var saturation: CGFloat = 0.5 {
        didSet {
            delegate?.saturationBrightnessPickerViewDidUpdateColor(currentColor())
            setNeedsDisplay()
        }
    }
    
    private var brightness: CGFloat = 0.5 {
        didSet {
            delegate?.saturationBrightnessPickerViewDidUpdateColor(currentColor())
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
        clipsToBounds = false
        backgroundColor = UIColor.clearColor()
        opaque = false
        bounds = CGRectInset(bounds, -inset, -inset)
    }
    
    func currentColor() -> UIColor
    {
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
    }
    
    override func drawRect(rect: CGRect)
    {
        let rectToDraw = CGRectInset(rect, inset, inset)
        
        let ctx = UIGraphicsGetCurrentContext()
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        CGContextSaveGState(ctx)
        CGContextClipToRect(ctx, rectToDraw)
        
        let colors = [UIColor(hue: hue, saturation: 1.0, brightness: 1.0, alpha: 1.0).CGColor,
            UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).CGColor]
        
        let gradient = CGGradientCreateWithColors(colorSpace, colors, [CGFloat(0.0), CGFloat(1.0)])
        CGContextDrawLinearGradient(ctx, gradient, CGPoint(x: rectToDraw.size.width, y: 0), CGPointZero, 0)
        
        let desaturatedColors = [UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0).CGColor,
            UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0).CGColor]
        
        let desaturatedGradient = CGGradientCreateWithColors(colorSpace, desaturatedColors, [CGFloat(0.0), CGFloat(1.0)])
        CGContextDrawLinearGradient(ctx, desaturatedGradient, CGPointZero, CGPoint(x: 0, y: rectToDraw.size.height), 0)
        
        CGContextRestoreGState(ctx)
        
        let adjustedPoint = CGPoint(x: saturation * CGRectGetWidth(rectToDraw), y: CGRectGetHeight(rectToDraw) - (brightness * CGRectGetHeight(rectToDraw)))
        let reticuleRect = CGRect(x: adjustedPoint.x - (reticuleSize / 2), y: adjustedPoint.y - (reticuleSize / 2), width: reticuleSize, height: reticuleSize)
        
        CGContextAddEllipseInRect(ctx, CGRectInset(reticuleRect, 4, 4))
        CGContextSetFillColorWithColor(ctx, currentColor().CGColor)
        CGContextSetStrokeColorWithColor(ctx, currentColor().isDarkColor() ? UIColor.whiteColor().CGColor : UIColor.blackColor().CGColor)
        CGContextSetLineWidth(ctx, 1)
        CGContextClosePath(ctx)
        CGContextDrawPath(ctx, kCGPathEOFillStroke)
    }
    
    //MARK: - HuePickerViewDelegate -
    func huePickerViewDidUpdateHue(hue: CGFloat)
    {
        self.hue = hue
    }
    
    //MARK: - Touches -
    private func handleTouches(touches: Set<NSObject>)
    {
        let touch = touches.first as! UITouch
        let point = touch.locationInView(self)
        
        let width = CGRectGetWidth(bounds) - (inset * 2)
        let height = CGRectGetHeight(bounds) - (inset * 2)
        
        if point.x < 0 {
            saturation = 0
        }
        else if point.x > width {
            saturation = 1
        }
        else {
            saturation = point.x / width
        }
        
        if point.y < 0 {
            brightness = 1
        }
        else if point.y > height {
            brightness = 0
        }
        else {
            brightness = 1 - (point.y / height)
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
