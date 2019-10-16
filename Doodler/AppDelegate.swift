
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        application.applicationSupportsShakeToEdit = true
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        if let window = window {
            AppController.sharedController.showInWindow(window)
        }
        
        return true
    }
        
}

