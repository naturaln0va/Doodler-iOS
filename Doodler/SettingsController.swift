//
//  Created by Ryan Ackermann on 6/13/15.
//  Copyright (c) 2015 Ryan Ackermann. All rights reserved.
//

import UIKit

class SettingsController: NSObject
{
    // Singleton Instance
    static let sharedController = SettingsController()
    
    // Defaults Keys
    static private let kStrokeWidthKey = "kStrokeWidthKey"
    static private let kStrokeColorKey = "kStrokeColorKey"
    
    private let defaults = NSUserDefaults.standardUserDefaults()
    
    lazy private var baseDefaults: Dictionary<String, AnyObject> = {
        return [kStrokeWidthKey: 12.0, kStrokeColorKey: [0.0, 0.0, 0.0]]
    }()
    
    override init()
    {
        super.init()
        loadSettings()
    }
    
    //MARK: - Public
    func currentStrokeWidth() -> Float
    {
        return defaults.floatForKey("kStrokeWidthKey")
    }
    
    func setStrokeWidth(width: Float) {
        defaults.setFloat(width, forKey: "kStrokeWidthKey")
        defaults.synchronize()
    }
    
    func currentStrokeColor() -> UIColor
    {
        let colorComponents = defaults.arrayForKey("kStrokeColorKey") as! [CGFloat]
        return UIColor(red: colorComponents[0], green: colorComponents[1], blue: colorComponents[2], alpha: 1.0)
    }
    
    func setStrokeColor(color: UIColor) {
        defaults.setObject(color.rgb(), forKey: "kStrokeColorKey")
        defaults.synchronize()
    }
    
    // MARK: - Private
    private func loadSettings()
    {
        defaults.registerDefaults(baseDefaults)
    }
}