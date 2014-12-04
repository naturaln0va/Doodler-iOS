//
//  SettingsViewController.swift
//  DrawingApp
//
//  Created by Ryan Ackermann on 11/6/14.
//  Copyright (c) 2014 Ryan Ackermann. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var lineWidthSlider: UISlider!
    @IBOutlet weak var lineLabel: UILabel!
    @IBOutlet weak var lineView: PreView!
    
    let defaults = NSUserDefaults.standardUserDefaults()
    @IBOutlet weak var rgbView: UIView!
    @IBOutlet weak var redSlider: UISlider!
    @IBOutlet weak var greenSlider: UISlider!
    @IBOutlet weak var blueSlider: UISlider!
    @IBOutlet weak var colorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lineWidthSlider.setValue(Float(defaults.objectForKey("lineWidth") as CGFloat), animated: true)
        hexToRGBSliders(defaults.objectForKey("color") as Int)
        colorLabel.text = "Color: #\(componentToHex(Int(redSlider.value)))\(componentToHex(Int(greenSlider.value)))\(componentToHex(Int(blueSlider.value)))"
        rgbView.layer.cornerRadius = 11.0
        rgbView.backgroundColor = colorFromSliders()
        lineView.drawColor = colorFromSliders()
        lineView.lineWidth = CGFloat(lineWidthSlider.value)
        lineView.setNeedsDisplay()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        defaults.synchronize()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    @IBAction func redChange(sender: AnyObject) {
        rgbView.backgroundColor = colorFromSliders()
        lineView.drawColor = colorFromSliders()
        colorLabel.text = "Color: #\(componentToHex(Int(redSlider.value)))\(componentToHex(Int(greenSlider.value)))\(componentToHex(Int(blueSlider.value)))"
        lineView.setNeedsDisplay()
    }
    
    @IBAction func greenChange(sender: AnyObject) {
        rgbView.backgroundColor = colorFromSliders()
        lineView.drawColor = colorFromSliders()
        colorLabel.text = "Color: #\(componentToHex(Int(redSlider.value)))\(componentToHex(Int(greenSlider.value)))\(componentToHex(Int(blueSlider.value)))"
        lineView.setNeedsDisplay()
    }
    
    @IBAction func blueChange(sender: AnyObject) {
        rgbView.backgroundColor = colorFromSliders()
        lineView.drawColor = colorFromSliders()
        colorLabel.text = "Color: #\(componentToHex(Int(redSlider.value)))\(componentToHex(Int(greenSlider.value)))\(componentToHex(Int(blueSlider.value)))"
        lineView.setNeedsDisplay()
    }
    
    @IBAction func strokeWidthAction(sender: AnyObject) {
        lineView.lineWidth = CGFloat(lineWidthSlider.value)
        lineView.setNeedsDisplay()
    }
    
    @IBAction func cancelSettings() {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
        })
    }
    
    @IBAction func saveSettings() {
        defaults.setObject(rgbToHex(componentToHex(Int(redSlider.value)), g: componentToHex(Int(greenSlider.value)), b: componentToHex(Int(blueSlider.value))), forKey: "color")
        defaults.setObject(CGFloat(lineWidthSlider.value), forKey: "lineWidth")
        defaults.synchronize()
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
        })
    }
    
    func hexToRGBSliders(hex: Int) {
        let red = Float((hex & 0xFF0000) >> 16)
        let green = Float((hex & 0xFF00) >> 8)
        let blue = Float(hex & 0xFF)
        
        redSlider.setValue(red, animated: true)
        greenSlider.setValue(green, animated: true)
        blueSlider.setValue(blue, animated: true)
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
    
    func colorFromSliders() -> UIColor {
        let r = CGFloat(redSlider.value) / 255.0
        let g = CGFloat(greenSlider.value) / 255.0
        let b = CGFloat(blueSlider.value) / 255.0
        
        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
    }

}
