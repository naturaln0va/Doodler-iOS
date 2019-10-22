
import UIKit

class AppController: NSObject {
    
    static let shared = AppController()
    
    private var window: UIWindow!
    
    var rootViewController: UIViewController? {
        didSet {
            window.rootViewController = rootViewController
        }
    }
    
    lazy var doodlesNC: NavigationController = {
        let nc = NavigationController(DoodlesViewController())
        
        nc.navigationBar.barTintColor = UIColor.black
        nc.navigationBar.tintColor = UIColor.tintColor.withAlphaComponent(0.6)
        
        nc.toolbar.barTintColor = nc.navigationBar.barTintColor
        nc.toolbar.tintColor = nc.navigationBar.tintColor
        
        let baseTitleAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.tintColor
        ]
        nc.navigationBar.titleTextAttributes = baseTitleAttributes
        nc.navigationBar.largeTitleTextAttributes = baseTitleAttributes
        
        return nc
    }()
    
    func showInWindow(_ window: UIWindow) {
        self.window = window
        
        rootViewController = doodlesNC
        window.makeKeyAndVisible()
    }

}
