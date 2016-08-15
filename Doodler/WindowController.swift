
import UIKit

@UIApplicationMain
class WindowController: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        application.applicationSupportsShakeToEdit = true;
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        if let window = window {
            MenuController.sharedController.showInWindow(window)
        }
        
        return true
    }
}

