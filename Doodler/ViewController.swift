//
//  Created by Ryan Ackermann on 11/6/14.
//  Copyright (c) 2014 Ryan Ackermann. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import AssetsLibrary

class ViewController: UIViewController, UIGestureRecognizerDelegate, RAScrollablePickerViewDelegate, UIScrollViewDelegate
{
    var canvas: DrawableView!
    var colorButtonView: ColorPreviewButton!
    
    var scrollView: UIScrollView!
    
    //Outlets
    @IBOutlet weak var controlBar: UIToolbar!
    @IBOutlet weak var colorButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet var drawingSegmentedControl: UISegmentedControl!
    @IBOutlet weak var strokeSizeSlider: UISlider!
    @IBOutlet var bottomToolbarConstraint: NSLayoutConstraint!
    @IBOutlet var infoView: UIView!
    @IBOutlet var infoLabel: UILabel!
    
    @IBOutlet weak var colorPreview: ColorPreView!
    @IBOutlet weak var previousColorLabel: UILabel!
    @IBOutlet weak var newColorLabel: UILabel!
    @IBOutlet weak var huePicker: RAScrollablePickerView!
    @IBOutlet weak var saturationPicker: RAScrollablePickerView!
    @IBOutlet weak var brightnessPicker: RAScrollablePickerView!
    
    private lazy var tapGesture: UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: "handleTap:")
    }()
    
    //MARK: - VC Delegate
    override func canBecomeFirstResponder() -> Bool
    {
        return true
    }
    
    override func prefersStatusBarHidden() -> Bool
    {
        return true
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        drawingSegmentedControl.selectedSegmentIndex = 1
        
        bottomToolbarConstraint.constant = 0
        view.layoutIfNeeded()
        
        view.insertSubview(GridView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)), belowSubview: controlBar)
        
        infoView.alpha = 0
        infoView.layer.cornerRadius = 10
        infoView.layer.borderColor = UIColor.whiteColor().CGColor
        infoView.layer.borderWidth = 1
        
        colorButtonView = ColorPreviewButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        colorButtonView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "colorButtonTapped"))
        colorButton.customView = colorButtonView
        
        strokeSizeSlider.setValue(SettingsController.sharedController.currentStrokeWidth(), animated: false)
        strokeSizeSlider.setMinimumTrackImage(UIImage.imageOfSize(CGSize(width: 2, height: 16), ofColor: UIColor(hex: 0xA6A6A6, alpha: 0.5)).resizableImageWithCapInsets(UIEdgeInsets(top: 8, left: 1, bottom: 8, right: 1)), forState: .Normal)
        strokeSizeSlider.setMaximumTrackImage(UIImage.imageOfSize(CGSize(width: 2, height: 16), ofColor: UIColor(hex: 0xE5E5E5, alpha: 0.5)).resizableImageWithCapInsets(UIEdgeInsets(top: 8, left: 1, bottom: 8, right: 1)), forState: .Normal)
        strokeSizeSlider.setThumbImage(UIImage(named: "thumb"), forState: .Normal)
        
        huePicker.delegate = self
        
        saturationPicker.delegate = self
        saturationPicker.type = .Saturation
        saturationPicker.hueValueForPreview = huePicker.value
        
        brightnessPicker.delegate = self
        brightnessPicker.type = .Brightness
        brightnessPicker.hueValueForPreview = huePicker.value
        
        colorButtonView.color = SettingsController.sharedController.currentStrokeColor()
        
        scrollView = UIScrollView(frame: view.bounds)
        scrollView.delegate = self
        scrollView.panGestureRecognizer.minimumNumberOfTouches = 2
        view.insertSubview(scrollView, belowSubview: controlBar)
        
        delay(0.25) {
            self.setUpWithSize(CGSize(width: 1024.0, height: 1024.0))
        }
    }
    
    func setUpWithSize(size: CGSize)
    {
        if let canvas = canvas {
            canvas.removeFromSuperview()
            self.canvas = nil
        }
        
        canvas = DrawableView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        canvas.center = view.center
        canvas.userInteractionEnabled = true
        canvas.alpha = 0.0

        scrollView.addSubview(canvas)
        scrollView.contentSize = canvas.bounds.size
        
        let scrollViewFrame = scrollView.frame
        let scaleWidth = scrollViewFrame.size.width / scrollView.contentSize.width
        let scaleHeight = scrollViewFrame.size.height / scrollView.contentSize.height
        let minScale = min(scaleWidth, scaleHeight);
        scrollView.minimumZoomScale = minScale;
        
        let canvasTransformValue = CGRectGetWidth(view.frame) / CGRectGetWidth(canvas.frame)
        canvas.transform = CGAffineTransformMakeScale(canvasTransformValue, canvasTransformValue)
        
        scrollView.maximumZoomScale = 7.0
        scrollView.zoomScale = minScale;
        
        centerScrollViewContents()
        
        UIView.animateWithDuration(0.25, animations: {
            self.canvas.alpha = 1.0
        })
    }
    
    //MARK: - Gestures
    func handleTap(gesture: UITapGestureRecognizer)
    {
        if let gestureView = gesture.view {
            let point = gesture.locationInView(gestureView)
            
            if point.y < CGRectGetMaxY(controlBar.frame) {
                if bottomToolbarConstraint.constant > 0 {
                    let updatedColor = UIColor(hue: huePicker.value, saturation: saturationPicker.value, brightness: brightnessPicker.value, alpha: 1)
                    SettingsController.sharedController.setStrokeColor(updatedColor)
                    
                    colorButtonView.color = updatedColor
                    
                    bottomToolbarConstraint.constant = 0
                }
                
                UIView.animateWithDuration(0.25, delay: 0.0, usingSpringWithDamping: 1.25, initialSpringVelocity: 5.0, options: nil, animations: {
                    
                    self.view.layoutIfNeeded()
                    
                }, completion: nil)
            }
        }
    }
    
    //MARK: - Button Actions
    func clearScreen()
    {
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
    
    func colorButtonTapped()
    {
        RAAudioEngine.sharedEngine.play(.TapSoundEffect)
        
        if bottomToolbarConstraint.constant > 0 {
            let updatedColor = UIColor(hue: huePicker.value, saturation: saturationPicker.value, brightness: brightnessPicker.value, alpha: 1)
            SettingsController.sharedController.setStrokeColor(updatedColor)
            
            colorButtonView.color = updatedColor
            
            bottomToolbarConstraint.constant = 0
            
            view.removeGestureRecognizer(tapGesture)
        } else {
            if let hue = SettingsController.sharedController.currentStrokeColor().hsb()!.first {
                huePicker.value = hue
                saturationPicker.hueValueForPreview = hue
                brightnessPicker.hueValueForPreview = hue
            }
            
            let currentColor = SettingsController.sharedController.currentStrokeColor()
            
            saturationPicker.value = currentColor.hsb()![1]
            brightnessPicker.value = currentColor.hsb()![2]

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
            
            view.addGestureRecognizer(tapGesture)
        }
        
        UIView.animateWithDuration(0.25, delay: 0.0, usingSpringWithDamping: 1.25, initialSpringVelocity: 5.0, options: nil, animations: {
        
            self.view.layoutIfNeeded()
            
        }, completion: nil)
    }
    
    @IBAction func saveTapped()
    {
        // add a thing for the user to edit share text
        RAAudioEngine.sharedEngine.play(.TapSoundEffect)
        
        let activityViewcontroller = UIActivityViewController(activityItems: ["Made with Doodler", canvas.imageByCapturing()], applicationActivities: [NewDocumentActivity()])
        activityViewcontroller.excludedActivityTypes = [
            UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard, UIActivityTypePrint
        ]
        activityViewcontroller.completionWithItemsHandler = { (activityType: String!, completed: Bool, returnedItems: [AnyObject]!, activityError: NSError!) in
            if activityType == nil {
                return
            }
            
            if activityType == kActivityTypeNewDocument {
                delay(0.25) {
                    self.setUpWithSize(CGSize(width: 1024.0, height: 1024.0))
                }
            }
            
            if activityType == UIActivityTypeSaveToCameraRoll {
                RAAudioEngine.sharedEngine.play(.SaveSoundEffect)
                self.showMessageBannerWithText("Image Saved", color: UIColor(hex: 0x27ae60), completion: {
                    let alertController = UIAlertController(title: "New Document", message: "Would you like to create a new document?", preferredStyle: .Alert)
                    
                    let cancelAction = UIAlertAction(title: "No, thanks", style: .Cancel) { _ in
                    }
                    alertController.addAction(cancelAction)
                    
                    let destroyAction = UIAlertAction(title: "Yes, please", style: .Default) { _ in
                        delay(0.25) {
                            self.setUpWithSize(CGSize(width: 1024.0, height: 1024.0))
                        }
                    }
                    alertController.addAction(destroyAction)
                    
                    self.presentViewController(alertController, animated: true, completion: nil)
                })
            }
        }
        presentViewController(activityViewcontroller, animated: true, completion: {})
    }
    
    @IBAction func drawingSegmentWasChanged(sender: UISegmentedControl)
    {
        if sender.selectedSegmentIndex == 0 {
            SettingsController.sharedController.enableEraser()
        } else if sender.selectedSegmentIndex == 1 {
            SettingsController.sharedController.disableEraser()
        }
    }
    
    @IBAction func strokeSliderUpdated(sender: UISlider)
    {
        SettingsController.sharedController.setStrokeWidth(sender.value)
        updateInfoForInfoView("Size: \(Int(sender.value))")
    }
    
    //MARK: - UIGestureRecognizer Delegate
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool
    {
        
        if gestureRecognizer.isKindOfClass(UIPanGestureRecognizer.self) || otherGestureRecognizer.isKindOfClass(UIPinchGestureRecognizer.self) {
            return true
        }
        
        return false
    }
    
    //MARK: - Helper Functions
    func updateInfoForInfoView(info: String)
    {
        infoLabel.text = info
        
        UIView.animateWithDuration(0.25, animations: {
            self.infoView.alpha = 1
        })
        
        delay(2, {
            UIView.animateWithDuration(0.25, animations: {
                self.infoView.alpha = 0
            })
        })
    }
    
    func centerScrollViewContents()
    {
        let boundsSize = scrollView.bounds.size
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
        
        canvas.frame = contentsFrame
    }
    
    func showMessageBannerWithText(text: String, color: UIColor, completion: (() -> Void)?)
    {
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
    
    //MARK: - UIScrollViewDelegate
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView?
    {
        return canvas
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView)
    {
        centerScrollViewContents()
    }
    
    //MARK: - Motion Event Delegate
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent)
    {
        if motion == .MotionShake {
            clearScreen()
        }
    }
}

