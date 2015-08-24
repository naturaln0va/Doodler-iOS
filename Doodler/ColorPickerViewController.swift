//
//  Created by Ryan Ackermann on 8/13/15.
//  Copyright (c) 2015 Ryan Ackermann. All rights reserved.
//

import UIKit

protocol ColorPickerViewControllerDelegate
{
    func colorPickerViewControllerDidPickColor(color: UIColor)
}

class ColorPickerViewController: RHAViewController, SaturationBrightnessPickerViewDelegate
{
    
    @IBOutlet weak var colorPreView: ColorPreView!
    @IBOutlet weak var previousColorLabel: UILabel!
    @IBOutlet weak var currentColorLabel: UILabel!
    
    @IBOutlet weak var saturationBrightnessPickerView: SaturationBrightnessPickerView!
    @IBOutlet weak var huePickerView: HuePickerView!
    
    var delegate: ColorPickerViewControllerDelegate?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        title = "Choose"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "doneButtonPressed")
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancelButtonPressed")
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSForegroundColorAttributeName: RHAColorController.barTintColor, NSFontAttributeName: UIFont(name: "AvenirNextCondensed-Regular", size: 20.0)!], forState: .Normal)
        navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSForegroundColorAttributeName: RHAColorController.barTintColor, NSFontAttributeName: UIFont(name: "AvenirNextCondensed-Regular", size: 20.0)!], forState: .Normal)
        
        huePickerView.layer.cornerRadius = 4
        huePickerView.delegate = saturationBrightnessPickerView
        saturationBrightnessPickerView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool)
    {
        let currentColor = SettingsController.sharedController.currentStrokeColor()
        saturationBrightnessPickerView.setColorToDisplay(currentColor)
        colorPreView.previousColor = currentColor
        colorPreView.newColor = currentColor
        
        previousColorLabel.text = currentColor.hexString()
        currentColorLabel.text = currentColor.hexString()
        
        if currentColor.isDarkColor() {
            previousColorLabel.textColor = UIColor.whiteColor()
            currentColorLabel.textColor = UIColor.whiteColor()
        } else {
            previousColorLabel.textColor = UIColor.blackColor()
            currentColorLabel.textColor = UIColor.blackColor()
        }
        
        if let hue = SettingsController.sharedController.currentStrokeColor().hsb()!.first {
            huePickerView.hue = hue
        }
    }
    
    func doneButtonPressed()
    {
        delegate?.colorPickerViewControllerDidPickColor(saturationBrightnessPickerView.currentColor())
        
        dismiss()
    }
    
    func cancelButtonPressed()
    {
        dismiss()
    }
    
    private func dismiss()
    {
        if isIPad() {
            if let popOver = MenuController.sharedController.canvasVC.popOverView {
                popOver.dismissPopoverAnimated(true)
            }
        }
        else {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    //MARK: - SaturationBrightnessPickerViewDelegate Methods -
    func saturationBrightnessPickerViewDidUpdateColor(color: UIColor)
    {
        colorPreView.newColor = color
        currentColorLabel.text = color.hexString()
        
        if color.isDarkColor() {
            currentColorLabel.textColor = UIColor.whiteColor()
        } else {
            currentColorLabel.textColor = UIColor.blackColor()
        }
    }
    
}
