
import UIKit

class NavigationController: UINavigationController {
    
    init(_ rootVC: UIViewController) {
        super.init(nibName: nil, bundle: nil)
        
        pushViewController(rootVC, animated: false)
        initComplete()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initComplete() {
        toolbar.tintColor = .doodlerRed
        navigationBar.tintColor = .doodlerRed
        navigationBar.prefersLargeTitles = true
    }

    override var shouldAutorotate: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return shouldAutorotate ? .all : .portrait
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}
