
import UIKit

@UIApplicationMain
class WindowController: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        application.applicationSupportsShakeToEdit = true
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        if let window = window {
            AppController.sharedController.showInWindow(window)
        }
        
        return true
    }
    
}

