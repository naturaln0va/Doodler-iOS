
import UIKit

class MenuController {
    
    static let sharedController = MenuController()
    
    var presenterViewController: UIViewController?
    
    lazy var doodlesNC: StyledNavigationController = {
        return StyledNavigationController(rootViewController: DoodlesViewController())
    }()
    
    lazy var canvasVC: CanvasViewController = {
        return CanvasViewController()
    }()
    
    lazy var colorPickerVC: ColorPickerViewController = {
        return ColorPickerViewController()
    }()
        
    func showInWindow(_ window: UIWindow) {
        window.rootViewController = doodlesNC
        window.makeKeyAndVisible()
    }
    
}
