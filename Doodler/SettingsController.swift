
import UIKit

let kSettingsControllerStrokeWidthDidChange: String = "kSettingsControllerStrokeWidthDidChange"
let kSettingsControllerStrokeColorDidChange: String = "kSettingsControllerStrokeColorDidChange"

class SettingsController: NSObject {
    // Singleton Instance
    static let shared = SettingsController()
    
    // Defaults Keys
    static internal let kStrokeWidthKey = "strokeWidthKey"
    static internal let kStrokeColorKey = "strokeColorKey"
    static internal let kEraserEnabledKey = "eraserEnabledKey"
    
    private let defaults = UserDefaults(suiteName: "group.io.ackermann.doodlesharing") ?? UserDefaults.standard
    
    lazy private var baseDefaults: [String: Any] = {
        return [kStrokeWidthKey: 12.0, kStrokeColorKey: [0.898, 0.078, 0.078]]
    }()
    
    override init() {
        super.init()
        loadSettings()
    }
    
    //MARK: - Public
    var strokeWidth: Float {
        return defaults.float(forKey: SettingsController.kStrokeWidthKey)
    }
    
    func setStrokeWidth(_ width: Float) {
        defaults.set(width, forKey: SettingsController.kStrokeWidthKey)
        defaults.synchronize()
        NotificationCenter.default.post(name: Notification.Name(rawValue: kSettingsControllerStrokeWidthDidChange), object: nil)
    }
    
    func enableEraser() {
        defaults.set(true, forKey: SettingsController.kEraserEnabledKey)
        defaults.synchronize()
    }
    
    func disableEraser() {
        defaults.set(false, forKey: SettingsController.kEraserEnabledKey)
        defaults.synchronize()
    }
    
    var eraserEnabled: Bool {
        return defaults.bool(forKey: SettingsController.kEraserEnabledKey)
    }
    
    var strokeColor: UIColor {
        let colorComponents = defaults.array(forKey: SettingsController.kStrokeColorKey) as! [CGFloat]
        return UIColor(red: colorComponents[0], green: colorComponents[1], blue: colorComponents[2], alpha: 1.0)
    }
    
    func setStrokeColor(_ color: UIColor) {
        defaults.set(color.rgb(), forKey: SettingsController.kStrokeColorKey)
        defaults.synchronize()
        NotificationCenter.default.post(name: Notification.Name(rawValue: kSettingsControllerStrokeColorDidChange), object: nil)
    }
    
    // MARK: - Private
    private func loadSettings() {
        defaults.register(defaults: baseDefaults)
    }
}
