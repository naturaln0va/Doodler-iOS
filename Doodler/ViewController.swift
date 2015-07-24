//
//  Created by Ryan Ackermann on 11/6/14.
//  Copyright (c) 2014 Ryan Ackermann. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import AssetsLibrary

class ViewController: UIViewController, UIGestureRecognizerDelegate, RANewDocumentControllerDelegate, RAScrollablePickerViewDelegate
{
    var canvas: DrawableView!
    var colorButtonView: ColorPreviewButton!
    
    var drawingScale: CGFloat = 1.0
    var previousScale: CGFloat = 0.0
    var panningCoord: CGPoint?
    
    //Outlets
    @IBOutlet weak var controlBar: UIToolbar!
    @IBOutlet weak var colorButton: UIBarButtonItem!
    @IBOutlet weak var pencilButton: UIBarButtonItem!
    @IBOutlet weak var eraserButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var strokeSizeSlider: UISlider!
    @IBOutlet var bottomToolbarConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var colorPreview: ColorPreView!
    @IBOutlet weak var previousColorLabel: UILabel!
    @IBOutlet weak var newColorLabel: UILabel!
    @IBOutlet weak var huePicker: RAScrollablePickerView!
    @IBOutlet weak var saturationPicker: RAScrollablePickerView!
    @IBOutlet weak var brightnessPicker: RAScrollablePickerView!
    
    private lazy var pinchGesture: UIPinchGestureRecognizer = {
        let pinch = UIPinchGestureRecognizer(target: self, action: "handlePinch:")
        pinch.delegate = self
        return pinch
    }()
    
    private lazy var panGesture: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer(target: self, action: "handlePan:")
        pan.minimumNumberOfTouches = 2
        pan.delegate = self
        return pan
    }()
    
    //MARK: - VC Delegate
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bottomToolbarConstraint.constant = 0
        view.layoutIfNeeded()
        
        view.insertSubview(GridView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)), belowSubview: controlBar)
        
        colorButtonView = ColorPreviewButton(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
        colorButton.customView = colorButtonView
        strokeSizeSlider.setValue(SettingsController.sharedController.currentStrokeWidth(), animated: false)
        
        huePicker.delegate = self
        
        saturationPicker.delegate = self
        saturationPicker.type = .Saturation
        saturationPicker.hueValueForPreview = huePicker.value
        
        brightnessPicker.delegate = self
        brightnessPicker.type = .Brightness
        brightnessPicker.hueValueForPreview = huePicker.value
        
        colorButtonView.color = SettingsController.sharedController.currentStrokeColor()
        
        delay(0.5) {
            self.setUpWithSize(CGSize(width: 1024.0, height: 1024.0))
        }
    }
    
    func setUpWithSize(size: CGSize) {
        if let canvas = canvas {
            canvas.removeFromSuperview()
            self.canvas = nil
        }
        
        canvas = DrawableView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        canvas.center = view.center
        canvas.userInteractionEnabled = true
        canvas.alpha = 0.0
        canvas.addGestureRecognizer(pinchGesture)
        canvas.addGestureRecognizer(panGesture)
        
        view.insertSubview(canvas, belowSubview: controlBar)
        
        centerScrollViewContents()
        
        UIView.animateWithDuration(0.4, animations: {
            self.canvas.alpha = 1.0
        })
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    //MARK: - Gestures
    
    func handlePan(gesture: UIPanGestureRecognizer)
    {
        if let gestureView = gesture.view {
            if gesture.state == .Began {
                panningCoord = gesture.locationInView(gestureView)
            }
            
            if let panCoord = panningCoord {
                let newCoord = gesture.locationInView(gestureView)
                let dx = (newCoord.x - panCoord.x) * 0.25
                let dy = (newCoord.y - panCoord.y) * 0.25
                
                gestureView.frame = CGRect(x: gestureView.frame.origin.x + dx, y: gestureView.frame.origin.y + dy, width: gestureView.frame.size.width, height: gestureView.frame.size.height)
            }
        }
    }
    
    func handlePinch(gesture: UIPinchGestureRecognizer)
    {
        if let drawingCanvas = canvas {
            if gesture.state == .Began {
                previousScale = drawingScale
            }
            let currScale = max(min(gesture.scale * drawingScale, 10.0), 0.25)
            let scaleStep = currScale / previousScale
            
            drawingCanvas.transform = CGAffineTransformScale(drawingCanvas.transform, scaleStep, scaleStep)
            
            previousScale = currScale
            
            if gesture.state == .Ended || gesture.state == .Cancelled || gesture.state == .Failed {
                drawingScale = currScale
                
                centerScrollViewContents()
            }
        }
    }
    
    //MARK: - Button Actions
    
    func clearScreen() {
        let alertController = UIAlertController(title: "Clear Screen?", message: "This cannot be undone.", preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { _ in
        }
        alertController.addAction(cancelAction)
        
        let destroyAction = UIAlertAction(title: "Clear", style: .Destructive) { _ in
            RAAudioEngine.sharedEngine.play(.ClearSoundEffect)
            self.canvas.clear()
        }
        alertController.addAction(destroyAction)
        
        self.presentViewController(alertController, animated: true) {
            // ...
        }
    }
    
    @IBAction func colorButtonTapped()
    {
        RAAudioEngine.sharedEngine.play(.TapSoundEffect)
        
        if bottomToolbarConstraint.constant > 0 {
            let updatedColor = UIColor(hue: huePicker.value, saturation: saturationPicker.value, brightness: brightnessPicker.value, alpha: 1)
            SettingsController.sharedController.setStrokeColor(updatedColor)
            
            colorButtonView.color = updatedColor
            
            bottomToolbarConstraint.constant = 0
        } else {
            if let hue = SettingsController.sharedController.currentStrokeColor().hsb()!.first {
                huePicker.value = hue
                saturationPicker.hueValueForPreview = hue
                brightnessPicker.hueValueForPreview = hue
            }
            
            let currentColor = SettingsController.sharedController.currentStrokeColor()
            
            colorPreview.previousColor = currentColor
            colorPreview.newColor = currentColor
            
            previousColorLabel.text = currentColor.hexString()
            newColorLabel.text = currentColor.hexString()
            
            if currentColor.isDarkColor() {
                previousColorLabel.textColor = UIColor.whiteColor()
                newColorLabel.textColor = UIColor.whiteColor()
            } else {
                previousColorLabel.textColor = UIColor.blackColor()
                newColorLabel.textColor = UIColor.blackColor()
            }
            
            bottomToolbarConstraint.constant = 400
        }
        
        UIView.animateWithDuration(0.25, delay: 0.0, usingSpringWithDamping: 1.25, initialSpringVelocity: 5.0, options: nil, animations: {
        
            self.view.layoutIfNeeded()
            
        }, completion: nil)
    }
    
    @IBAction func saveTapped() {
        // add a thing for the user to edit share text
        
        RAAudioEngine.sharedEngine.play(.TapSoundEffect)
        
        let image = canvas.imageByCapturing()
        let authStatus = ALAssetsLibrary.authorizationStatus()
        if authStatus == .Authorized {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                UIImageWriteToSavedPhotosAlbum(image, self, Selector("image:didFinishSavingWithError:contextInfo:"), nil)
            })
        } else if authStatus == .Denied {
            showMessageBannerWithText("Photo Access Blocked", color: UIColor.redColor(), completion: nil)
        } else if authStatus == .NotDetermined {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                UIImageWriteToSavedPhotosAlbum(image, self, Selector("image:didFinishSavingWithError:contextInfo:"), nil)
            })
        }
        
    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSError!, contextInfo:UnsafePointer<Void>) {
        if error != nil {
            showMessageBannerWithText("Error Saving Image", color: UIColor(hex: 0xc0392b), completion: nil)
        }
        RAAudioEngine.sharedEngine.play(.SaveSoundEffect)
        showMessageBannerWithText("Image Saved", color: UIColor(hex: 0x27ae60), completion: {
            let alertController = UIAlertController(title: "New Document", message: "Would you like to create a new document?", preferredStyle: .Alert)
            
            let cancelAction = UIAlertAction(title: "No, thanks", style: .Cancel) { _ in
            }
            alertController.addAction(cancelAction)
            
            let destroyAction = UIAlertAction(title: "Yes, please", style: .Default) { _ in
                self.delay(0.2) {
                    self.setUpWithSize(CGSize(width: 1024.0, height: 1024.0))
                }
            }
            alertController.addAction(destroyAction)
            
            self.presentViewController(alertController, animated: true) {
                // ...
            }
        })
    }
    
    @IBAction func strokeSliderUpdated(sender: UISlider) {
        SettingsController.sharedController.setStrokeWidth(sender.value)
    }
    
    @IBAction func eraserButtonTapped(sender: AnyObject) {
        RAAudioEngine.sharedEngine.play(.TapSoundEffect)
        
        //drawingCanvas.eraserEnabled = true
    }
    
    @IBAction func pencilButtonTapped(sender: AnyObject) {
        RAAudioEngine.sharedEngine.play(.TapSoundEffect)
        
        //drawingCanvas.eraserEnabled = false
    }
    
    //MARK: - UIGestureRecognizer Delegate
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if gestureRecognizer.isKindOfClass(UIPinchGestureRecognizer.self) || otherGestureRecognizer.isKindOfClass(UIPinchGestureRecognizer.self) {
            return true
        }
        
        if gestureRecognizer.isKindOfClass(UIPanGestureRecognizer.self) || otherGestureRecognizer.isKindOfClass(UIPanGestureRecognizer.self) {
            return true
        }
        
        return false
    }
    
    //MARK: - Helper Functions
    
    func centerScrollViewContents()
    {
        let boundsSize = view.bounds.size
        var contentsFrame = canvas.frame
        
        if contentsFrame.size.width < boundsSize.width {
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0
        } else {
            contentsFrame.origin.x = 0.0
        }
        
        if contentsFrame.size.height < boundsSize.height {
            contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0
        } else {
            contentsFrame.origin.y = 0.0
        }
        
        UIView.animateWithDuration(0.2, animations: {
            self.canvas.frame = contentsFrame
        })
    }
    
    func setBrushToErase() {
        SettingsController.sharedController.setStrokeColor(UIColor.whiteColor())
    }
    
    func showMessageBannerWithText(text: String, color: UIColor, completion: (() -> Void)?) {
        let bannerHeight: CGFloat = 54.0
        var banner = UIView(frame: CGRect(x: 0, y: -bannerHeight - 25, width: self.view.frame.size.width, height: bannerHeight * 2))
        banner.backgroundColor = color
        
        var label = UILabel(frame: CGRect(x: 0, y: 13, width: banner.frame.width, height: (bannerHeight * 2)))
        label.textAlignment = .Center
        label.text = text
        label.font = UIFont(name: "AvenirNext-Medium", size: 37.0)
        label.textColor = UIColor(hex: 0xecf0f1)
        banner.addSubview(label)
        self.view.addSubview(banner)
        let b = banner.bounds
        UIView.animateWithDuration(0.93, delay: 0.0, usingSpringWithDamping: 0.3, initialSpringVelocity: 5.0, options: .CurveEaseOut, animations: { () -> Void in
            banner.center = CGPoint(x: b.origin.x + b.size.width/2, y: bannerHeight/2)
        }) { _ in
            UIView.animateWithDuration(0.93, delay: 0.69, usingSpringWithDamping: 0.7, initialSpringVelocity: 4.0, options: .CurveEaseIn, animations: { () -> Void in
                banner.center = CGPoint(x: b.origin.x + b.size.width/2, y: -bannerHeight)
                }) { _ in
                    completion!()
                    banner.removeFromSuperview()
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "newDocument" {
            let newDocVC: RANewDocumentViewController = segue.destinationViewController as! RANewDocumentViewController
            newDocVC.delegate = self
        }
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    // MARK: RAScrollablePickerViuewDelegate
    func valueChanged(value: CGFloat, type: PickerType)
    {
        var changedColor: UIColor
        
        switch(type) {
        case .Hue:
            changedColor = UIColor(hue: value, saturation: saturationPicker.value, brightness: brightnessPicker.value, alpha: 1)
            saturationPicker.hueValueForPreview = value
            brightnessPicker.hueValueForPreview = value
        case .Saturation:
            changedColor = UIColor(hue: huePicker.value, saturation: value, brightness: brightnessPicker.value, alpha: 1)
        case .Brightness:
            changedColor = UIColor(hue: huePicker.value, saturation: saturationPicker.value, brightness: value, alpha: 1)
        }
        
        colorPreview.newColor = changedColor
        newColorLabel.text = changedColor.hexString()
        if changedColor.isDarkColor() {
            newColorLabel.textColor = UIColor.whiteColor()
        } else {
            newColorLabel.textColor = UIColor.blackColor()
        }
    }
    
    //MARK: - New Document Delegate
    func newDocumentControllerDidCancel(controller: RANewDocumentViewController) {
        // nothing for now
    }
    
    func newDocumentControllerDidFinish(controller: RANewDocumentViewController, size: CGSize) {
        self.dismissViewControllerAnimated(true, completion: nil)
        self.setUpWithSize(size)
    }
    
    //MARK: - Motion Event Delegate
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent) {
        if motion == .MotionShake {
            clearScreen()
        }
    }
}

