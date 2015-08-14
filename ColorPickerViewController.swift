//
//  ColorPickerViewController.swift
//  Doodler
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
        
        title = "Pick A Color"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "doneButtonPressed")
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancelButtonPressed")
                
        if let hue = SettingsController.sharedController.currentStrokeColor().hsb()!.first {
            huePickerView.hue = hue
            saturationBrightnessPickerView.hue = hue
        }
        
        let currentColor = SettingsController.sharedController.currentStrokeColor()
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
        
        huePickerView.delegate = saturationBrightnessPickerView
        saturationBrightnessPickerView.delegate = self
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
        dismissViewControllerAnimated(true, completion: nil)
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
