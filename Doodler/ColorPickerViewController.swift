//
//  Created by Ryan Ackermann on 8/13/15.
//  Copyright (c) 2015 Ryan Ackermann. All rights reserved.
//

import UIKit

protocol ColorPickerViewControllerDelegate
{
    func colorPickerViewControllerDidPickColor(_ color: UIColor)
}

class ColorPickerViewController: UIViewController, SaturationBrightnessPickerViewDelegate
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(ColorPickerViewController.doneButtonPressed))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(ColorPickerViewController.cancelButtonPressed))
        
        huePickerView.layer.cornerRadius = 4
        huePickerView.delegate = saturationBrightnessPickerView
        saturationBrightnessPickerView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        let currentColor = SettingsController.sharedController.currentStrokeColor()
        saturationBrightnessPickerView.setColorToDisplay(currentColor)
        colorPreView.previousColor = currentColor
        colorPreView.newColor = currentColor
        
        previousColorLabel.text = currentColor.hexString()
        currentColorLabel.text = currentColor.hexString()
        
        if currentColor.isDarkColor() {
            previousColorLabel.textColor = UIColor.white
            currentColorLabel.textColor = UIColor.white
        } else {
            previousColorLabel.textColor = UIColor.black
            currentColorLabel.textColor = UIColor.black
        }
        
        if let hue = SettingsController.sharedController.currentStrokeColor().hsb()!.first {
            huePickerView.hue = hue
        }
    }
    
    func doneButtonPressed() {
        delegate?.colorPickerViewControllerDidPickColor(saturationBrightnessPickerView.currentColor)
        
        dismiss()
    }
    
    func cancelButtonPressed() {
        dismiss()
    }
    
    private func dismiss() {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - SaturationBrightnessPickerViewDelegate Methods -
    func saturationBrightnessPickerViewDidUpdateColor(_ color: UIColor)
    {
        colorPreView.newColor = color
        currentColorLabel.text = color.hexString()
        
        if color.isDarkColor() {
            currentColorLabel.textColor = UIColor.white
        } else {
            currentColorLabel.textColor = UIColor.black
        }
    }
    
}
