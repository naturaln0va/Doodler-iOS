
import UIKit

protocol ColorPickerViewControllerDelegate {
    func colorPickerViewControllerDidPickColor(_ color: UIColor)
}

class ColorPickerViewController: UIViewController, SaturationBrightnessPickerViewDelegate {
    
    @IBOutlet weak var colorPreView: ColorPreView!
    @IBOutlet weak var previousColorLabel: UILabel!
    @IBOutlet weak var currentColorLabel: UILabel!
    
    @IBOutlet weak var saturationBrightnessPickerView: SaturationBrightnessPickerView!
    @IBOutlet weak var huePickerView: HuePickerView!
    
    var delegate: ColorPickerViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        huePickerView.layer.cornerRadius = 4
        huePickerView.delegate = saturationBrightnessPickerView
        
        saturationBrightnessPickerView.delegate = self
        saturationBrightnessPickerView.backgroundColor = view.backgroundColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let currentColor = SettingsController.sharedController.strokeColor
        saturationBrightnessPickerView.setColorToDisplay(currentColor)
        colorPreView.previousColor = currentColor
        colorPreView.newColor = currentColor
        
        previousColorLabel.text = currentColor.hexString
        currentColorLabel.text = currentColor.hexString
        
        if currentColor.isDarkColor() {
            previousColorLabel.textColor = UIColor.white
            currentColorLabel.textColor = UIColor.white
        } else {
            previousColorLabel.textColor = UIColor.black
            currentColorLabel.textColor = UIColor.black
        }
        
        if let hue = SettingsController.sharedController.strokeColor.hsb()!.first {
            huePickerView.hue = hue
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        delegate?.colorPickerViewControllerDidPickColor(saturationBrightnessPickerView.currentColor)
    }
    
    //MARK: - SaturationBrightnessPickerViewDelegate Methods -
    func saturationBrightnessPickerViewDidUpdateColor(_ color: UIColor) {
        colorPreView.newColor = color
        currentColorLabel.text = color.hexString
        
        if color.isDarkColor() {
            currentColorLabel.textColor = UIColor.white
        } else {
            currentColorLabel.textColor = UIColor.black
        }
    }
    
}
