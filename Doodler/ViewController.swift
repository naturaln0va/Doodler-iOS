//
//  ViewController.swift
//  DrawingApp
//
//  Created by Ryan Ackermann on 11/6/14.
//  Copyright (c) 2014 Ryan Ackermann. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import AssetsLibrary
import AudioToolbox

class ViewController: UIViewController, MCBrowserViewControllerDelegate, MCSessionDelegate, SphereMenuDelegate {

    var drawView: DrawView!
    var menu: SphereMenu!
    let notificationCenter = NSNotificationCenter.defaultCenter()
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var tapAudioEffect: SystemSoundID = 0
    var saveAudioEffect: SystemSoundID = 0
    var clearAudioEffect: SystemSoundID = 0
    
    let service = "drawing"
    
    var browser: MCBrowserViewController!
    var assistant: MCAdvertiserAssistant!
    var session: MCSession!
    var peerID: MCPeerID!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let w = UIScreen.mainScreen().nativeBounds.width / UIScreen.mainScreen().scale
        let h = UIScreen.mainScreen().nativeBounds.height / UIScreen.mainScreen().scale
        let heightForView = round(h - 69)
        
        drawView = DrawView(frame: CGRect(x: 0, y: 0, width: w, height: h))
        drawView.contentScaleFactor = UIScreen.mainScreen().scale
        drawView.backgroundColor = UIColor.whiteColor()
        drawView.userInteractionEnabled = true
        view.addSubview(drawView)
        
        let start = UIImage(named: "StartButton")
        let settingsButton = UIImage(named: "SettingsButton")
        let saveButton = UIImage(named: "SaveButton")
        let clearButton = UIImage(named: "TrashButton")
        let connectButton = UIImage(named: "ConnectButton")
        var images: [UIImage] = [settingsButton!, saveButton!, clearButton!, connectButton!]
        menu = SphereMenu(startPoint: CGPoint(x: (start!.size.width / 2) + 15, y: CGRectGetMaxY(self.view.frame) - (start!.size.height / 2) - 15), startImage: start!, submenuImages: images)
        menu.delegate = self
        self.view.addSubview(menu)
        
        var tapSoundPath = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("woody_click", ofType: "wav")!)
        var saveSoundPath = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("music_marimba_chord", ofType: "wav")!)
        var clearSoundPath = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("short_whoosh1", ofType: "wav")!)
        
        AudioServicesCreateSystemSoundID(tapSoundPath! as CFURLRef, &tapAudioEffect)
        AudioServicesCreateSystemSoundID(saveSoundPath! as CFURLRef, &saveAudioEffect)
        AudioServicesCreateSystemSoundID(clearSoundPath! as CFURLRef, &clearAudioEffect)
        
        self.peerID = MCPeerID(displayName: UIDevice.currentDevice().name)
        self.session = MCSession(peer: peerID)
        self.session.delegate = self
        
        //Creation of the browser controller
        self.browser = MCBrowserViewController(serviceType: service, session: self.session)
        self.browser.delegate = self
        
        self.assistant = MCAdvertiserAssistant(serviceType: service, discoveryInfo: nil, session: self.session)
        
        self.assistant.start()
        
        notificationCenter.addObserver(self, selector: Selector("lineToSend"), name: "NOTIFICATION_LINE_TO_SEND", object: drawView)
        notificationCenter.addObserver(self, selector: Selector("shutDownAdvertiser"), name: "NOTIFICATION_SHUT_DOWN_ADVERTISER", object: UIApplication.sharedApplication().delegate)
        notificationCenter.addObserver(self, selector: Selector("startAdvertiser"), name: "NOTIFICATION_START_ADVERTISER", object: UIApplication.sharedApplication().delegate)
        
        defaults.setObject(10.0, forKey: "lineWidth")
        defaults.setObject(0x000000, forKey: "color")
    }
    
    override func viewWillAppear(animated: Bool) {
        if defaults.objectForKey("lineWidth") as CGFloat > 0 {
            drawView.lineWidth = defaults.objectForKey("lineWidth") as CGFloat
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        //AudioServicesDisposeSystemSoundID(tapAudioEffect)
        //AudioServicesDisposeSystemSoundID(saveAudioEffect)
        
        defaults.synchronize()
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            let location = touch.locationInView(self.view)
            if CGRectContainsPoint(menu.frame, location) {
                AudioServicesPlaySystemSound(tapAudioEffect)
            }
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func clearTapped() {
        let alertController = UIAlertController(title: "Clear Screen?", message: "This cannot be undone.", preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { _ in
            print("Crisis Averted :)")
        }
        alertController.addAction(cancelAction)
        
        let destroyAction = UIAlertAction(title: "Clear", style: .Destructive) { _ in
            AudioServicesPlaySystemSound(self.clearAudioEffect)
            self.drawView.image = nil
            self.drawView.bufferImageView.image = nil
        }
        alertController.addAction(destroyAction)
        
        self.presentViewController(alertController, animated: true) {
            // ...
        }
    }
    
    func saveTapped() {
        UIGraphicsBeginImageContextWithOptions(self.drawView.frame.size, false, 0.0)
        drawView.image?.drawInRect(CGRect(x: 0, y: 0, width: self.drawView.frame.size.width, height: self.drawView.frame.size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let authStatus = ALAssetsLibrary.authorizationStatus()
        if authStatus == .Authorized {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                UIImageWriteToSavedPhotosAlbum(image, self, Selector("image:didFinishSavingWithError:contextInfo:"), nil)
            })
        } else if authStatus == .Denied {
            showMessageBannerWithText("Photo Access Blocked", color: UIColor.redColor())
        } else if authStatus == .NotDetermined {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                UIImageWriteToSavedPhotosAlbum(image, self, Selector("image:didFinishSavingWithError:contextInfo:"), nil)
            })
        }
        
    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSError!, contextInfo:UnsafePointer<Void>) {
        if error != nil {
            showMessageBannerWithText("Error Saving Image", color: UIColor(hex: 0xc0392b))
        }
        AudioServicesPlaySystemSound(saveAudioEffect)
        showMessageBannerWithText("Image Saved", color: UIColor(hex: 0x27ae60))
    }
    
    func showBrowser() {
        self.presentViewController(browser, animated: true, completion: nil)
    }
    
    func showSettings() {
        performSegueWithIdentifier("settings", sender: self)
    }
    
    func lineToSend() {
        if self.session.connectedPeers.count > 0 {
            sendLine()
        }
    }
    
    func showMessageBannerWithText(text: String, color: UIColor) {
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
        let hexIntColor = defaults.objectForKey("color") as Int
        let color = UIColor(hex: hexIntColor)
        let components = CGColorGetComponents(color.CGColor)
        let red = Float(components[0]) * 255
        let green = Float(components[1]) * 255
        let blue = Float(components[2]) * 255
        
        let hexColor: Int = rgbToHex(componentToHex(Int(red)), g: componentToHex(Int(green)), b: componentToHex(Int(blue)))
        
        let width = defaults.objectForKey("lineWidth") as CGFloat
        
        var error: NSError?
        
        if drawView.moving {
            let msg = "\(Int(drawView.newPoint.x)),\(Int(drawView.newPoint.y)),\(Int(drawView.lastPoint.x)),\(Int(drawView.lastPoint.y)),\(Int(hexColor)),\(Int(width))".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
            
            self.session.sendData(msg, toPeers: self.session.connectedPeers, withMode: .Reliable, error: &error)
        } else {
            let msg = "\(Int(drawView.lastPoint.x)),\(Int(drawView.lastPoint.y)),\(Int(drawView.lastPoint.x)),\(Int(drawView.lastPoint.y)),\(Int(hexColor)),\(Int(width))".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
            
            self.session.sendData(msg, toPeers: self.session.connectedPeers, withMode: .Reliable, error: &error)
        }
        
        if error != nil {
            println("Error sending data: \(error?.localizedDescription)")
        }
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
        let width: Int = lineComponents[5].toInt()!
        
        drawView.setUpAndDraw(CGFloat(width), color: color, lastX: startPoint.x, lastY: startPoint.y, x: endPoint.x, y: endPoint.y)
        
    }
    
    func componentToHex(component: Int) -> String {
        if component == 0 {
            return "00"
        } else {
            return NSString(format: "%2X", component)
        }
    }
    
    func rgbToHex(r: String, g: String, b: String) -> Int {
        let charArray = "0x\(r)\(g)\(b)"
        return Int(strtol(charArray, nil, 0))
    }
    
    //MARK: - SphereMenu Delegate
    
    func sphereDidSelected(index: Int) {
        switch index {
        case 0:
            showSettings()
            AudioServicesPlaySystemSound(tapAudioEffect)
        case 1:
            saveTapped()
            AudioServicesPlaySystemSound(tapAudioEffect)
        case 2:
            clearTapped()
            AudioServicesPlaySystemSound(tapAudioEffect)
        case 3:
            showBrowser()
            AudioServicesPlaySystemSound(tapAudioEffect)
        default:
            println("\(index)")
        }
        
    }
    
    //MARK: - Browser Delegate
    
    func browserViewControllerDidFinish(browserViewController: MCBrowserViewController!) {
        
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
    }
    
    func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController!) {
        
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
    }
    
    //MARK: - MCSession Delegate
    
    func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!) {
        
        dispatch_async(dispatch_get_main_queue()) {
            
            var msg = NSString(data: data, encoding: NSUTF8StringEncoding)
            
            self.updateDrawViewForMessage(msg!)
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


}

