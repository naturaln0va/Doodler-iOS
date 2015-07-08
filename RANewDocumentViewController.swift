//
//  RANewDocumentViewController.swift
//  Doodler
//
//  Created by Ryan Ackermann on 2/18/15.
//  Copyright (c) 2015 Ryan Ackermann. All rights reserved.
//

import UIKit

class RANewDocumentViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var canvasWidthTextField: UITextField!
    @IBOutlet weak var canvasHeightTextField: UITextField!
    
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var shakableView: UIView!
    
    var delegate: RANewDocumentControllerDelegate?
    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    //MARK: - Touche
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        self.view.endEditing(true)
    }
    
    //MARK: - TextField Delegate
    func textFieldDidBeginEditing(textField: UITextField) {
        slideContentUp()
        
        if !textField.text.isEmpty {
            textField.text = ""
            textField.textColor = UIColor(hex: 0x0080FF)
        }
        
        if errorView.alpha > 0.0 {
            UIView.animateWithDuration(0.4, animations: {
                self.errorView.alpha = 0.0
            })
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField.text.isEmpty {
            textField.text = "0"
        }
        slideContentDown()
    }
    
    //MARK: - Actions
    @IBAction func createButtonAction(sender: AnyObject) {
        appDelegate.audioEngine.play(SoundEffect.TapSoundEffect)
        let width: Int = canvasWidthTextField.text.toInt()!
        let height: Int = canvasHeightTextField.text.toInt()!
        
        if width * height > 1562500 || width > 1250 || height > 1250 {
            self.view.endEditing(true)
            self.errorLabel.text = "Error: Document too large"
            self.canvasWidthTextField.text = "1250"
            canvasWidthTextField.textColor = UIColor.redColor()
            self.canvasHeightTextField.text = "1250"
            canvasHeightTextField.textColor = UIColor.redColor()
            appDelegate.audioEngine.play(SoundEffect.ErrorSoundEffect)
            shake(shakableView, magnitude: 3)
            UIView.animateWithDuration(0.3, animations: {
                self.errorView.alpha = 1.0
            })
        } else if width <= 0 || height <= 0 {
            self.view.endEditing(true)
            self.errorLabel.text = "Error: A dimension cannot be zero"
            if width <= 0 {
                canvasWidthTextField.textColor = UIColor.redColor()
            } else if height <= 0 {
                canvasHeightTextField.textColor = UIColor.redColor()
            }
            appDelegate.audioEngine.play(SoundEffect.ErrorSoundEffect)
            shake(shakableView, magnitude: 3)
            UIView.animateWithDuration(0.3, animations: {
                self.errorView.alpha = 1.0
            })
        } else {
            self.delegate!.newDocumentControllerDidFinish(self, size: CGSize(width: width, height: height))
        }
    }
    
    // MARK: - Helpers
    func shake(view: UIView, magnitude: Float) {
        let keyFrameAnimation = CAKeyframeAnimation(keyPath: "bounds")
        keyFrameAnimation.duration = 0.35
        keyFrameAnimation.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut), CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut), CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)]
        let initalBounds = NSValue(CGRect: view.bounds)
        let secondBounds = NSValue(CGRect: CGRect(x: CGFloat(10 * magnitude), y: 0, width: CGFloat(view.bounds.size.width), height: CGFloat(view.bounds.size.height)))
        let thirdBounds = NSValue(CGRect: CGRect(x: -CGFloat(10 * magnitude), y: 0, width: CGFloat(view.bounds.size.width), height: CGFloat(view.bounds.size.height)))
        let finalBounds = NSValue(CGRect: view.bounds)
        keyFrameAnimation.values = [initalBounds, secondBounds, thirdBounds, finalBounds]
        keyFrameAnimation.keyTimes = [0, 0.35, 0.65, 1]
        
        view.layer.addAnimation(keyFrameAnimation, forKey: "shake")
    }
    
    func slideContentUp() {
        UIView.animateWithDuration(0.4, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0, options: .CurveEaseOut, animations: { _ in
            self.view.bounds.origin.y = 135
            }, completion: nil)
    }
    
    func slideContentDown() {
        UIView.animateWithDuration(0.4, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0, options: .CurveEaseOut, animations: { _ in
            self.view.bounds.origin.y = 0
            }, completion: nil)
    }
}