//
//  Created by Ryan Ackermann on 11/6/14.
//  Copyright (c) 2014 Ryan Ackermann. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import AssetsLibrary

class CanvasViewController: RHAViewController, UIGestureRecognizerDelegate, UIScrollViewDelegate, ColorPickerViewControllerDelegate
{
    private let kDefaultCanvasSize = CGSize(width: UIScreen.mainScreen().bounds.size.width, height: UIScreen.mainScreen().bounds.size.height)
    
    var canvas: DrawableView!
    var popOverView: UIPopoverController?
    var colorButtonView: ColorPreviewButton!
    var scrollView: UIScrollView!
    var hasBeingInitiallySetup = false
    
    //Outlets
    @IBOutlet weak var controlBar: UIToolbar!
    @IBOutlet weak var colorButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var undoButton: UIBarButtonItem!
    @IBOutlet var drawingSegmentedControl: UISegmentedControl!
    @IBOutlet weak var strokeSizeSlider: UISlider!
    @IBOutlet var infoView: AutoHideView!
    @IBOutlet var infoLabel: UILabel!
    
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
        SettingsController.sharedController.disableEraser()
        
        infoView.alpha = 0
        infoView.layer.cornerRadius = 10
        infoView.layer.borderColor = UIColor.whiteColor().CGColor
        infoView.layer.borderWidth = 1
        
        colorButtonView = ColorPreviewButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        colorButtonView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "colorButtonTapped"))
        colorButton.customView = colorButtonView
        
        strokeSizeSlider.setValue(SettingsController.sharedController.currentStrokeWidth(), animated: false)
        strokeSizeSlider.setMinimumTrackImage(UIImage(named: "slider"), forState: .Normal)
        strokeSizeSlider.setMaximumTrackImage(UIImage(named: "slider"), forState: .Normal)
        strokeSizeSlider.setThumbImage(UIImage(named: "knob"), forState: .Normal)
        
        colorButtonView.color = SettingsController.sharedController.currentStrokeColor()
        shareButton.action = "shareButtonTapped"
        undoButton.action = "undoButtonTapped"
    }
    
    override func viewWillLayoutSubviews()
    {
        if !hasBeingInitiallySetup {
            hasBeingInitiallySetup = true
            view.insertSubview(GridView(frame: CGRect(x: 0, y: 0, width: CGRectGetWidth(view.bounds), height: CGRectGetHeight(view.bounds))), belowSubview: controlBar)
            
            scrollView = UIScrollView(frame: view.bounds)
            scrollView.delegate = self
            scrollView.panGestureRecognizer.minimumNumberOfTouches = 2
            view.insertSubview(scrollView, belowSubview: controlBar)
            
            setUpWithSize(kDefaultCanvasSize)
        }
    }
    
    func setUpWithSize(size: CGSize)
    {
        if let canvas = canvas {
            canvas.removeFromSuperview()
            self.canvas = nil
            CacheController.sharedController.invalidateCache()
        }
        
        canvas = DrawableView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        canvas.layer.magnificationFilter = kCAFilterLinear
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
        
        scrollView.maximumZoomScale = 12.5
        scrollView.minimumZoomScale = 0.25
        scrollView.zoomScale = minScale;
        
        centerScrollViewContents()
        
        UIView.animateWithDuration(0.25, animations: {
            self.canvas.alpha = 1.0
        })
    }
    
    //MARK: - Button Actions
    func clearScreen()
    {
        let alert = SCLAlertView()
        alert.showCloseButton = false
        alert.addButton("Clear") {
            RAAudioEngine.sharedEngine.play(.ClearSoundEffect)
            self.canvas.clear()
        }
        alert.addButton("Cancel") { }
        alert.showWarning("Clear Screen", subTitle: "Would you like to clear the screen?")
    }
    
    func colorButtonTapped()
    {
        RAAudioEngine.sharedEngine.play(.TapSoundEffect)
        
        MenuController.sharedController.colorPickerVC.delegate = self
        
        if isIPad() {
            popOverView = UIPopoverController(contentViewController: RHANavigationViewController(rootViewController: MenuController.sharedController.colorPickerVC))
            
            if let popOver = popOverView {
                popOver.popoverContentSize = CGSize(width: 320, height: 525)
                popOver.backgroundColor = MenuController.sharedController.colorPickerVC.view.backgroundColor
                popOver.presentPopoverFromBarButtonItem(colorButton, permittedArrowDirections: .Down, animated: true)
            }
        }
        else {
            presentViewController(RHANavigationViewController(rootViewController: MenuController.sharedController.colorPickerVC), animated: true, completion: nil)
        }
    }
    
    func undoButtonTapped()
    {
        RAAudioEngine.sharedEngine.play(.TapSoundEffect)
        
        canvas.undo()
    }
    
    func shareButtonTapped()
    {
        // add a thing for the user to edit share text
        RAAudioEngine.sharedEngine.play(.TapSoundEffect)
        
        let activityViewcontroller = UIActivityViewController(activityItems: ["Made with Doodler", NSURL(string: "http://apple.co/1IUYyFk")!, canvas.imageByCapturing()], applicationActivities: [NewDocumentActivity()])
        activityViewcontroller.excludedActivityTypes = [
            UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard, UIActivityTypePrint
        ]
        
        if !isIOS8OrLater() {
            activityViewcontroller.completionHandler = { (activityType, completed: Bool) in
                if activityType == nil {
                    return
                }
                
                if activityType == kActivityTypeNewDocument {
                    delay(0.25) {
                        self.setUpWithSize(self.kDefaultCanvasSize)
                    }
                }
                
                if activityType == UIActivityTypeSaveToCameraRoll && completed {
                    RAAudioEngine.sharedEngine.play(.SaveSoundEffect)
                    
                    self.showMessageBannerWithText("Image Saved", color: UIColor(hex: 0x27ae60)) {
                        let alert = SCLAlertView()
                        alert.showCloseButton = false
                        alert.addButton("Yes, please") {
                            delay(0.25) {
                                self.setUpWithSize(self.kDefaultCanvasSize)
                            }
                        }
                        alert.addButton("No, thanks") { }
                        alert.showInfo("New Document", subTitle: "Would you like to create a new document?")
                    }
                }
            }
        }
        else {
            activityViewcontroller.completionWithItemsHandler = { (activityType: String!, completed: Bool, returnedItems: [AnyObject]!, activityError: NSError!) in
                if activityType == nil {
                    return
                }
                
                if activityType == kActivityTypeNewDocument {
                    delay(0.25) {
                        self.setUpWithSize(self.kDefaultCanvasSize)
                    }
                }
                
                if activityType == UIActivityTypeSaveToCameraRoll {
                    RAAudioEngine.sharedEngine.play(.SaveSoundEffect)
                    
                    self.showMessageBannerWithText("Image Saved", color: UIColor(hex: 0x27ae60)) {
                        let alert = SCLAlertView()
                        alert.showCloseButton = false
                        alert.addButton("Yes, please") {
                            delay(0.25) {
                                self.setUpWithSize(self.kDefaultCanvasSize)
                            }
                        }
                        alert.addButton("No, thanks") { }
                        alert.showInfo("New Document", subTitle: "Would you like to create a new document?")
                    }
                }
            }
        }
        
        if isIPad() {
            popOverView = UIPopoverController(contentViewController: activityViewcontroller)
            if let popOver = popOverView {
                popOver.presentPopoverFromBarButtonItem(shareButton, permittedArrowDirections: .Down, animated: true)
            }
        }
        else {
            presentViewController(activityViewcontroller, animated: true, completion: {})
        }
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
    
    //MARK: - Helper Functions
    func updateInfoForInfoView(info: String)
    {
        infoLabel.text = info
        infoView.show()
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
    
    //MARK: - UIScrollViewDelegate
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView?
    {
        return canvas
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView)
    {
        let scale = Int(scrollView.zoomScale * 100)
        updateInfoForInfoView("\(scale)%")
        
        if scale > 750 {
            canvas.layer.magnificationFilter = kCAFilterNearest
        } else {
            canvas.layer.magnificationFilter = kCAFilterLinear
        }
        
        centerScrollViewContents()
    }
    
    //MARK: - ColorPickerViewControllerDelegate Methods -
    func colorPickerViewControllerDidPickColor(color: UIColor)
    {
        SettingsController.sharedController.setStrokeColor(color)
        
        colorButtonView.color = color
    }
    
    //MARK: - Motion Event Delegate
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent)
    {
        if motion == .MotionShake {
            clearScreen()
        }
    }
}

