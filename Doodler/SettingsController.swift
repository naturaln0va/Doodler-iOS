
import UIKit

let kSettingsControllerStrokeWidthDidChange: String = "kSettingsControllerStrokeWidthDidChange"
let kSettingsControllerStrokeColorDidChange: String = "kSettingsControllerStrokeColorDidChange"

class SettingsController: NSObject {
    // Singleton Instance
    static let shared = SettingsController()
    
    // Defaults Keys
    struct DefaultsKeys {
        static let strokeWidthKey = "strokeWidthKey"
        static let strokeColorKey = "strokeColorKey"
        static let eraserEnabledKey = "eraserEnabledKey"
    }
    
    private let defaults = UserDefaults(suiteName: "group.io.ackermann.doodlesharing") ?? UserDefaults.standard
    
    lazy private var baseDefaults: [String: Any] = {
        return [
            DefaultsKeys.strokeWidthKey: 12.0,
            DefaultsKeys.strokeColorKey: [0.898, 0.078, 0.078]
        ]
    }()
    
    override init() {
        super.init()
        loadSettings()
    }
    
    //MARK: - Public
    var strokeWidth: Float {
        get {
            return defaults.float(forKey: DefaultsKeys.strokeWidthKey)
        }
        set {
            defaults.set(newValue, forKey: DefaultsKeys.strokeWidthKey)
            NotificationCenter.default.post(name: Notification.Name(rawValue: kSettingsControllerStrokeWidthDidChange), object: nil)
        }
    }
    
    func enableEraser() {
        defaults.set(true, forKey: DefaultsKeys.eraserEnabledKey)
    }
    
    func disableEraser() {
        defaults.set(false, forKey: DefaultsKeys.eraserEnabledKey)
    }
    
    var eraserEnabled: Bool {
        return defaults.bool(forKey: DefaultsKeys.eraserEnabledKey)
    }
    
    var strokeColor: UIColor {
        guard let colorComponents = defaults.array(forKey: DefaultsKeys.strokeColorKey) as? [CGFloat] else {
            return .clear
        }
        return UIColor(red: colorComponents[0], green: colorComponents[1], blue: colorComponents[2], alpha: 1.0)
    }
    
    func setStrokeColor(_ color: UIColor) {
        defaults.set(color.rgb(), forKey: DefaultsKeys.strokeColorKey)
        NotificationCenter.default.post(name: Notification.Name(rawValue: kSettingsControllerStrokeColorDidChange), object: nil)
    }
    
    // MARK: - Private
    private func loadSettings() {
        defaults.register(defaults: baseDefaults)
    }
    
}
