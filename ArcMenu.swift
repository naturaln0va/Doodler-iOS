//
//  ArcMenu.swift
//  Doodler
//
//  Created by Ryan Ackermann on 3/28/15.
//  Copyright (c) 2015 Ryan Ackermann. All rights reserved.
//

import UIKit

enum DeviceCorner {
    case TopRightDeviceCorner,
    TopLeftDeviceCorner,
    BottomRightDeviceCorner,
    BottomLeftDeviceCorner
}

protocol ArcMenuDelegate {
    func itemSelectedAtIndex(index: Int)
    func menuDidRecieveTouch()
}

class ArcView: UIView {
    var fillColor: UIColor = UIColor(red: 88/255.0, green: 186/255.0, blue: 219/255.0, alpha: 1.0)
    var collisionShape: CAShapeLayer?
    var shapeSize: CGFloat!
    var iconSize: CGFloat!
    var closed: Bool = true
    var menuIconImages: Array<UIImage> = Array()
    var menuImageViews: Array<UIImageView> = Array()
    var delegate: ArcMenuDelegate?
    
    //MARK: - Init
    convenience init(parent: UIView, size: CGFloat, corner: DeviceCorner, images: [UIImage], color: UIColor = UIColor(red: 88/255.0, green: 186/255.0, blue: 219/255.0, alpha: 1.0)) {
        self.init()
        shapeSize = size
        iconSize = shapeSize - 20
        menuIconImages = images
        
        for image in menuIconImages {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: iconSize, height: iconSize))
            imageView.image = image
            imageView.contentMode = UIViewContentMode.ScaleAspectFill
            menuImageViews.append(imageView)
        }
        
        switch corner {
        case .TopRightDeviceCorner:
            frame = CGRect(x: CGRectGetWidth(parent.frame) - size, y: 0, width: size, height: size)
            layer.transform = CATransform3DMakeRotation(CGFloat(M_PI), 1.0, 1.0, 0.0)
        case .TopLeftDeviceCorner:
            frame = CGRect(x: 0, y: 0, width: size, height: size)
            layer.transform = CATransform3DMakeRotation(CGFloat(M_PI), 1.0, 0.0, 0.0)
        case .BottomRightDeviceCorner:
            frame = CGRect(x: CGRectGetWidth(parent.frame) - size, y: CGRectGetHeight(parent.frame) - size, width: size, height: size)
            layer.transform = CATransform3DMakeRotation(CGFloat(M_PI), 0.0, 1.0, 0.0)
        case .BottomLeftDeviceCorner:
            frame = CGRect(x: 0, y: CGRectGetHeight(parent.frame) - size, width: size, height: size)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    init() {
        super.init(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0))
        println("Setup with an empty from, this should not be used in most cases")
        sharedInit()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func sharedInit() {
        userInteractionEnabled = true
    }
    
    //MARK: - Touches
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.delegate!.menuDidRecieveTouch()
        let colorPulse = CABasicAnimation(keyPath: "fillColor")
        colorPulse.duration = 0.25
        colorPulse.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        colorPulse.fromValue = collisionShape!.fillColor
        colorPulse.toValue = UIColor(red: 70/255.0, green: 145/255.0, blue: 171/255.0, alpha: 1.0).CGColor
        collisionShape!.addAnimation(colorPulse, forKey: "ColorPulse")
        collisionShape!.fillColor = UIColor(red: 70/255.0, green: 145/255.0, blue: 171/255.0, alpha: 1.0).CGColor
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as? UITouch
        let point = touch!.locationInView(self)
        
        let colorPulse = CABasicAnimation(keyPath: "fillColor")
        colorPulse.duration = 0.25
        colorPulse.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        colorPulse.fromValue = collisionShape!.fillColor
        colorPulse.toValue = fillColor.CGColor
        collisionShape!.addAnimation(colorPulse, forKey: "ColorPulse")
        collisionShape!.fillColor = fillColor.CGColor
        
        for touch in touches {
            if !closed {
                var index = 0
                for menuItem in menuImageViews {
                    if CGRectContainsPoint(menuItem.frame, point) {
                        self.delegate!.itemSelectedAtIndex(index)
                    }
                    index++
                }
            }
        }
        
        if closed {
            closed = false
            let openMenu = CABasicAnimation(keyPath: "path")
            openMenu.duration = 0.3
            openMenu.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            openMenu.fromValue = collisionShape!.path
            openMenu.toValue = UIBezierPath(rect: CGRect(x: collisionShape!.position.x, y: collisionShape!.position.y, width: CGRectGetWidth(superview!.frame), height: shapeSize)).CGPath
            
            collisionShape?.addAnimation(openMenu, forKey: "open")
            let newFrame = CGRect(x: collisionShape!.position.x, y: collisionShape!.position.y, width: CGRectGetWidth(superview!.frame), height: shapeSize)
            collisionShape!.path = UIBezierPath(rect: newFrame).CGPath
            frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: newFrame.width, height: newFrame.height)
            
            let fadeAnim = CABasicAnimation(keyPath: "opacity")
            fadeAnim.duration = 0.15
            fadeAnim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            fadeAnim.fromValue = 0.0
            fadeAnim.toValue = 1.0
            
            for imageView in menuImageViews {
                imageView.layer.addAnimation(fadeAnim, forKey: "fade")
                imageView.alpha = 1.0
            }
        } else {
            closed = true
            let closeMenu = CABasicAnimation(keyPath: "path")
            closeMenu.duration = 0.2
            closeMenu.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            closeMenu.fromValue = collisionShape!.path
            closeMenu.toValue = createCustomPath(CGRect(x: collisionShape!.position.x, y: collisionShape!.position.y, width: shapeSize, height: shapeSize)).CGPath
            
            collisionShape?.addAnimation(closeMenu, forKey: "close")
            let newFrame = CGRect(x: collisionShape!.position.x, y: collisionShape!.position.y, width: shapeSize, height: shapeSize)
            collisionShape!.path = createCustomPath(newFrame).CGPath
            frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: newFrame.width, height: newFrame.height)
            
            let fadeAnim = CABasicAnimation(keyPath: "opacity")
            fadeAnim.duration = 0.15
            fadeAnim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            fadeAnim.fromValue = 1.0
            fadeAnim.toValue = 0.0
            
            for imageView in menuImageViews {
                imageView.layer.addAnimation(fadeAnim, forKey: "fade")
                imageView.alpha = 0.0
            }
        }
    }
    
    override func touchesCancelled(touches: Set<NSObject>!, withEvent event: UIEvent!) {
        let colorPulse = CABasicAnimation(keyPath: "fillColor")
        colorPulse.duration = 0.25
        colorPulse.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        colorPulse.fromValue = collisionShape!.fillColor
        colorPulse.toValue = fillColor.CGColor
        collisionShape!.addAnimation(colorPulse, forKey: "ColorPulse")
        collisionShape!.fillColor = fillColor.CGColor
    }
    
    //MARK: - Helper
    func createCustomPath(rect: CGRect) -> UIBezierPath {
        let minX = CGRectGetMinX(rect)
        let maxX = CGRectGetMaxX(rect)
        let minY = CGRectGetMinY(rect)
        let maxY = CGRectGetMaxY(rect)
        let path = UIBezierPath()
        
        path.moveToPoint(CGPoint(x: minX, y: maxY))
        path.addLineToPoint(CGPoint(x: minX, y: minY))
        path.addQuadCurveToPoint(CGPoint(x: maxX, y: maxY), controlPoint: CGPoint(x: maxX, y: minY))
        path.closePath()
        
        return path
    }
    
    //MARK: - Custom Overriding
    override func layoutSubviews() {
        super.layoutSubviews()
        if collisionShape == nil {
            collisionShape = CAShapeLayer()
            collisionShape!.path = createCustomPath(self.bounds).CGPath
            collisionShape!.fillColor = fillColor.CGColor
            layer.addSublayer(collisionShape)
            
            let numImages = menuImageViews.count
            let iconSize: CGSize = menuIconImages[0].size
            let deviceWidth: Float = Float(UIScreen.mainScreen().bounds.size.width)
            let spaceBetween: Float = (deviceWidth - (Float(numImages) * Float(iconSize.width))) / (Float(numImages) + 1)
            var index: Int = 1
            var buttonsAdded: Int = 0
            for imageView in menuImageViews {
                imageView.frame = CGRect(x: Int(Int(spaceBetween) * index + Int(iconSize.width) * buttonsAdded), y: 10, width: Int(CGRectGetWidth(imageView.bounds)), height: Int(CGRectGetHeight(imageView.bounds)))
                addSubview(imageView)
                index++
                buttonsAdded++
                imageView.alpha = 0.0
            }
        }
    }
    
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        if let shape = collisionShape {
            if CGPathContainsPoint(shape.path, nil, point, true) {
                return true
            } else {
                return false
            }
        }
        return false
    }
}
