
import UIKit

class AppController {
    
    static let sharedController = AppController()
    
    var presenterViewController: UIViewController?
    
    lazy var doodlesNC: StyledNavigationController = {
        return StyledNavigationController(rootViewController: DoodlesViewController())
    }()
    
    lazy var canvasVC: CanvasViewController = {
        return CanvasViewController()
    }()
            
    func showInWindow(_ window: UIWindow) {
        window.rootViewController = doodlesNC
        window.makeKeyAndVisible()
    }
    
}
