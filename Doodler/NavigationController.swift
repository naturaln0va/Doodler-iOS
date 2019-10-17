
import UIKit

class NavigationController: UINavigationController {
    
    init(_ rootVC: UIViewController) {
        super.init(nibName: nil, bundle: nil)
        pushViewController(rootVC, animated: false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        toolbar.tintColor = .doodlerRed
        navigationBar.tintColor = .doodlerRed
        navigationBar.prefersLargeTitles = true
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return topViewController?.preferredStatusBarStyle ?? .default
    }
    
}
