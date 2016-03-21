//
//  Created by Ryan Ackermann on 8/13/15.
//  Copyright (c) 2015 Ryan Ackermann. All rights reserved.
//

import UIKit

protocol ColorPickerViewControllerDelegate
{
    func colorPickerViewControllerDidPickColor(color: UIColor)
}

class ColorPickerViewController: RHAViewController, SaturationBrightnessPickerViewDelegate, UITextFieldDelegate
{
    
    @IBOutlet weak var colorPreView: ColorPreView!
    @IBOutlet weak var colorHexValueBackingView: UIView!
    @IBOutlet weak var colorHexTextField: UITextField!
    
    @IBOutlet weak var saturationBrightnessPickerView: SaturationBrightnessPickerView!
    @IBOutlet weak var huePickerView: HuePickerView!
    
    var delegate: ColorPickerViewControllerDelegate?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        title = "Choose"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "doneButtonPressed")
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancelButtonPressed")
        
        colorPreView.backgroundColor = UIColor.clearColor()
        
        huePickerView.layer.cornerRadius = 5
        colorHexValueBackingView.layer.cornerRadius = 5
        
        colorHexTextField.delegate = self
        
        huePickerView.delegate = saturationBrightnessPickerView
        saturationBrightnessPickerView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool)
    {
        let currentColor = SettingsController.sharedController.currentStrokeColor()
        saturationBrightnessPickerView.setColorToDisplay(currentColor)
        colorPreView.previousColor = currentColor
        colorPreView.newColor = currentColor
        
        colorHexTextField.text = currentColor.hexString()
        
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
    
    //MARK: - SaturationBrightnessPickerViewDelegate Methods
    func saturationBrightnessPickerViewDidUpdateColor(color: UIColor)
    {
        colorPreView.newColor = color
        colorHexTextField.text = color.hexString()
    }
    
    // MARK: - UITextField Delegate
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        if NSEqualRanges(range, NSRange(location: 0, length: 1)) && string == "" {
            return false
        }
        
        let strippedString = string.stringByTrimmingCharactersInSet(NSCharacterSet.hexadecimalCharacterSet())
        if strippedString.characters.count > 0 {
            return false
        }
        
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        
        
        textField.endEditing(true)
        
        return true
    }
    
}
