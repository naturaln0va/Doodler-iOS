//
//  Created by Ryan Ackermann on 6/13/15.
//  Copyright (c) 2015 Ryan Ackermann. All rights reserved.
//

import UIKit

let kSettingsControllerStrokeWidthDidChange: String = "kSettingsControllerStrokeWidthDidChange"
let kSettingsControllerStrokeColorDidChange: String = "kSettingsControllerStrokeColorDidChange"

class SettingsController: NSObject
{
    // Singleton Instance
    static let sharedController = SettingsController()
    
    // Defaults Keys
    static internal let kStrokeWidthKey = "strokeWidthKey"
    static internal let kStrokeColorKey = "strokeColorKey"
    static internal let kEraserEnabledKey = "eraserEnabledKey"
    
    private let defaults = NSUserDefaults.standardUserDefaults()
    
    lazy private var baseDefaults: Dictionary<String, AnyObject> = {
        return [kStrokeWidthKey: 12.0, kStrokeColorKey: [0.898, 0.078, 0.078]]
    }()
    
    override init()
    {
        super.init()
        loadSettings()
    }
    
    //MARK: - Public
    func currentStrokeWidth() -> Float
    {
        return defaults.floatForKey(SettingsController.kStrokeWidthKey)
    }
    
    func setStrokeWidth(width: Float)
    {
        defaults.setFloat(width, forKey: SettingsController.kStrokeWidthKey)
        defaults.synchronize()
        NSNotificationCenter.defaultCenter().postNotificationName(kSettingsControllerStrokeWidthDidChange, object: nil)
    }
    
    func enableEraser()
    {
        defaults.setBool(true, forKey: SettingsController.kEraserEnabledKey)
        defaults.synchronize()
    }
    
    func disableEraser()
    {
        defaults.setBool(false, forKey: SettingsController.kEraserEnabledKey)
        defaults.synchronize()
    }
    
    func isEraserEnabled() -> Bool
    {
        return defaults.boolForKey(SettingsController.kEraserEnabledKey)
    }
    
    func currentStrokeColor() -> UIColor
    {
        let colorComponents = defaults.arrayForKey(SettingsController.kStrokeColorKey) as! [CGFloat]
        return UIColor(red: colorComponents[0], green: colorComponents[1], blue: colorComponents[2], alpha: 1.0)
    }
    
    func currentDrawColor() -> UIColor
    {
        if isEraserEnabled() {
            return UIColor.whiteColor()
        }
        let colorComponents = defaults.arrayForKey(SettingsController.kStrokeColorKey) as! [CGFloat]
        return UIColor(red: colorComponents[0], green: colorComponents[1], blue: colorComponents[2], alpha: 1.0)
    }
    
    func setStrokeColor(color: UIColor)
    {
        defaults.setObject(color.rgb(), forKey: SettingsController.kStrokeColorKey)
        defaults.synchronize()
        NSNotificationCenter.defaultCenter().postNotificationName(kSettingsControllerStrokeColorDidChange, object: nil)
    }
    
    // MARK: - Private
    private func loadSettings()
    {
        defaults.registerDefaults(baseDefaults)
    }
}