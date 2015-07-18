//
//  Created by Ryan Ackermann on 11/6/14.
//  Copyright (c) 2014 Ryan Ackermann. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import AssetsLibrary

class ViewController: UIViewController, MCBrowserViewControllerDelegate, MCSessionDelegate, UIScrollViewDelegate, RANewDocumentControllerDelegate, UIGestureRecognizerDelegate, RAScrollablePickerViewDelegate
{
    var drawingCanvas: DrawableView!
    var scrollView: UIScrollView!
    
    let notificationCenter = NSNotificationCenter.defaultCenter()
    
    let service = "drawing"
    
    var browser: MCBrowserViewController!
    var assistant: MCAdvertiserAssistant!
    var session: MCSession!
    var peerID: MCPeerID!
    
    //Outlets
    @IBOutlet weak var controlBar: UIView!
    @IBOutlet weak var colorButton: ColorPreviewButton!
    @IBOutlet weak var pencilButton: UIButton!
    @IBOutlet weak var eraserButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var strokeSizeSlider: UISlider!
    @IBOutlet var bottomToolbarConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var colorPreview: ColorPreView!
    @IBOutlet weak var previousColorLabel: UILabel!
    @IBOutlet weak var newColorLabel: UILabel!
    @IBOutlet weak var huePicker: RAScrollablePickerView!
    @IBOutlet weak var saturationPicker: RAScrollablePickerView!
    @IBOutlet weak var brightnessPicker: RAScrollablePickerView!
    
    //MARK: - VC Delegate
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bottomToolbarConstraint.constant = 0
        view.layoutIfNeeded()
        
        view.insertSubview(GridView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)), belowSubview: controlBar)
        
        peerID = MCPeerID(displayName: UIDevice.currentDevice().name)
        session = MCSession(peer: peerID)
        session.delegate = self
        
        //Creation of the browser controller
        browser = MCBrowserViewController(serviceType: service, session: session)
        browser.delegate = self
        
        assistant = MCAdvertiserAssistant(serviceType: service, discoveryInfo: nil, session: session)
        assistant.start()
        
        notificationCenter.addObserver(self, selector: Selector("lineToSend"), name: "NOTIFICATION_LINE_TO_SEND", object: nil)
        notificationCenter.addObserver(self, selector: Selector("shutDownAdvertiser"), name: "NOTIFICATION_SHUT_DOWN_ADVERTISER", object: nil)
        notificationCenter.addObserver(self, selector: Selector("startAdvertiser"), name: "NOTIFICATION_START_ADVERTISER", object: nil)
        
        colorButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "colorButtonTapped"))
        strokeSizeSlider.setValue(SettingsController.sharedController.currentStrokeWidth(), animated: false)
        
        scrollView = UIScrollView(frame: view.bounds)
        scrollView.delegate = self
        scrollView.panGestureRecognizer.minimumNumberOfTouches = 2
        view.insertSubview(scrollView, belowSubview: controlBar)
        
        huePicker.delegate = self
        
        saturationPicker.delegate = self
        saturationPicker.type = .Saturation
        saturationPicker.hueValueForPreview = huePicker.value
        
        brightnessPicker.delegate = self
        brightnessPicker.type = .Brightness
        brightnessPicker.hueValueForPreview = huePicker.value
        
        colorButton.color = SettingsController.sharedController.currentStrokeColor()
        
        delay(0.5) {
            self.setUpWithSize(CGSize(width: 1024.0, height: 1024.0))
        }
    }
    
    func setUpWithSize(size: CGSize) {
        if let canvas = drawingCanvas {
            canvas.removeFromSuperview()
            drawingCanvas = nil
        }
        
        drawingCanvas = DrawableView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        drawingCanvas.center = view.center
        drawingCanvas.userInteractionEnabled = true
        drawingCanvas.alpha = 0.0
        
        scrollView.addSubview(drawingCanvas)
        scrollView.contentSize = drawingCanvas.bounds.size
        
        let scrollViewFrame = scrollView.frame
        let scaleWidth = scrollViewFrame.size.width / scrollView.contentSize.width
        let scaleHeight = scrollViewFrame.size.height / scrollView.contentSize.height
        let minScale = min(scaleWidth, scaleHeight);
        scrollView.minimumZoomScale = minScale;
        
        scrollView.maximumZoomScale = 7.0
        scrollView.zoomScale = minScale;
        
        centerScrollViewContents()
        
        UIView.animateWithDuration(0.4, animations: {
            self.drawingCanvas.alpha = 1.0
        })
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    //MARK: - Button Actions
    
    func clearScreen() {
        let alertController = UIAlertController(title: "Clear Screen?", message: "This cannot be undone.", preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { _ in
        }
        alertController.addAction(cancelAction)
        
        let destroyAction = UIAlertAction(title: "Clear", style: .Destructive) { _ in
            RAAudioEngine.sharedEngine.play(.ClearSoundEffect)
            self.drawingCanvas.clear()
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
            
            colorButton.color = updatedColor
            
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
        
        let image = drawingCanvas.imageByCapturing()
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
            if self.session.connectedPeers.count == 0 {
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
            }
        })
    }
    
    @IBAction func strokeSliderUpdated(sender: UISlider) {
        SettingsController.sharedController.setStrokeWidth(sender.value)
    }
    
    @IBAction func showBrowser() {
        RAAudioEngine.sharedEngine.play(.TapSoundEffect)
        
        self.presentViewController(browser, animated: true, completion: nil)
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
        let boundsSize = scrollView.bounds.size
        var contentsFrame = drawingCanvas.frame
        
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
        
        drawingCanvas.frame = contentsFrame
    }
    
    func setBrushToErase() {
        SettingsController.sharedController.setStrokeColor(UIColor.whiteColor())
    }
    
    func lineToSend() {
        if self.session.connectedPeers.count > 0 {
            sendLine()
        }
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
    
    func shutDownAdvertiser() {
        assistant.stop()
    }
    
    func startAdvertiser() {
        assistant.start()
    }
    
    func sendLine() {
//        let hexIntColor = defaults.objectForKey("color") as Int
//        let color = UIColor(hex: hexIntColor)
//        let components = CGColorGetComponents(color.CGColor)
//        let red = Float(components[0]) * 255
//        let green = Float(components[1]) * 255
//        let blue = Float(components[2]) * 255
//        
//        let hexColor: Int = rgbToHex(componentToHex(Int(red)), g: componentToHex(Int(green)), b: componentToHex(Int(blue)))
//        
//        let width = defaults.objectForKey("lineWidth") as CGFloat
//        
//        var error: NSError?
//        
//        if drawingCanvas.moving {
//            let msg = "\(Int(glDrawView.location.x)),\(Int(glDrawView.location.y)),\(Int(glDrawView.previousLocation.x)),\(Int(glDrawView.previousLocation.y)),\(Int(hexColor)),\(Int(width))".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
//            
//            self.session.sendData(msg, toPeers: self.session.connectedPeers, withMode: .Reliable, error: &error)
//        } else {
//            let msg = "\(Int(glDrawView.location.x)),\(Int(glDrawView.location.y)),\(Int(glDrawView.location.x)),\(Int(glDrawView.location.y)),\(Int(hexColor)),\(Int(width))".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
//            
//            self.session.sendData(msg, toPeers: self.session.connectedPeers, withMode: .Reliable, error: &error)
//        }
//        
//        if error != nil {
//            println("Error sending data: \(error?.localizedDescription)")
//        }
    }
    
    func updateDrawViewForMessage(msg: String) {
        let lineComponents = msg.componentsSeparatedByString(",")
        let startX = lineComponents[0].toInt()!
        let startY = lineComponents[1].toInt()!
        let endX = lineComponents[2].toInt()!
        let endY = lineComponents[3].toInt()!
        let startPoint = CGPoint(x: startX, y: startY)
        let endPoint = CGPoint(x: endX, y: endY)
        let color = UIColor(hex: lineComponents[4].toInt()!)
        let size: Int = lineComponents[5].toInt()!
        
//        glDrawView.renderLineFromPoint(startPoint, toPoint: endPoint)
    }
    
    func imageFromView(view: UIView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0)
        view.drawViewHierarchyInRect(view.bounds, afterScreenUpdates: false)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
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
    
    //MARK: - UIScrollViewDelegate
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView?
    {
        return drawingCanvas
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView)
    {
        centerScrollViewContents()
    }
    
    //MARK: - New Document Delegate
    func newDocumentControllerDidCancel(controller: RANewDocumentViewController) {
        // nothing for now
    }
    
    func newDocumentControllerDidFinish(controller: RANewDocumentViewController, size: CGSize) {
        self.dismissViewControllerAnimated(true, completion: nil)
        self.setUpWithSize(size)
    }
    
    //MARK: - Browser Delegate
    
    func browserViewControllerDidFinish(browserViewController: MCBrowserViewController!) {
        
        self.dismissViewControllerAnimated(true, completion: {
        })
    }
    
    func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController!) {
        
        self.dismissViewControllerAnimated(true, completion: {
        })
    }
    
    //MARK: - MCSession Delegate
    
    func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!) {
        
        dispatch_async(dispatch_get_main_queue()) {
            var msg = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
            self.updateDrawViewForMessage(msg)
        }
    }
    
    func session(session: MCSession!, didStartReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, withProgress progress: NSProgress!) {
        
    }
    
    func session(session: MCSession!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!) {
        
    }
    
    func session(session: MCSession!, didReceiveStream stream: NSInputStream!, withName streamName: String!, fromPeer peerID: MCPeerID!) {
        
    }
    
    func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState) {
        
    }
    
    //MARK: - Motion Event Delegate
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent) {
        if motion == .MotionShake {
            clearScreen()
        }
    }
}

