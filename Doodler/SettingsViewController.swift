//
//  Created by Ryan Ackermann on 11/6/14.
//  Copyright (c) 2014 Ryan Ackermann. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController
{
    @IBOutlet weak var rgbView: UIView!
    @IBOutlet weak var redSlider: UISlider!
    @IBOutlet weak var greenSlider: UISlider!
    @IBOutlet weak var blueSlider: UISlider!
    @IBOutlet weak var colorLabel: UILabel!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        setUpColorSlidersForColor(SettingsController.sharedController.currentStrokeColor())
        colorLabel.text = "Color: \(colorFromSliders().hexString()!)"
        rgbView.layer.cornerRadius = 11.0
        rgbView.backgroundColor = colorFromSliders()
    }
    
    override func prefersStatusBarHidden() -> Bool
    {
        return true
    }
    
    @IBAction func redChange(sender: AnyObject)
    {
        rgbView.backgroundColor = colorFromSliders()
        colorLabel.text = "Color: \(colorFromSliders().hexString()!)"
    }
    
    @IBAction func greenChange(sender: AnyObject)
    {
        rgbView.backgroundColor = colorFromSliders()
        colorLabel.text = "Color: \(colorFromSliders().hexString()!)"
    }
    
    @IBAction func blueChange(sender: AnyObject)
    {
        rgbView.backgroundColor = colorFromSliders()
        colorLabel.text = "Color: \(colorFromSliders().hexString()!)"
    }
    
    @IBAction func cancelSettings()
    {
        RAAudioEngine.sharedEngine.play(SoundEffect.TapSoundEffect)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func saveSettings()
    {
        RAAudioEngine.sharedEngine.play(SoundEffect.TapSoundEffect)
        SettingsController.sharedController.setStrokeColor(colorFromSliders())
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func setUpColorSlidersForColor(color: UIColor)
    {
        if let components = color.rgb() {
            redSlider.setValue(components[0] * 255.0, animated: true)
            greenSlider.setValue(components[1] * 255.0, animated: true)
            blueSlider.setValue(components[2] * 255.0, animated: true)
        }
    }
    
    private func colorFromSliders() -> UIColor
    {
        let r = CGFloat(redSlider.value) / 255.0
        let g = CGFloat(greenSlider.value) / 255.0
        let b = CGFloat(blueSlider.value) / 255.0
        
        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
    }
}
