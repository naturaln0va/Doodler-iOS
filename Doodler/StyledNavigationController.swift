
import UIKit

class StyledNavigationController: UINavigationController
{

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.barTintColor = UIColor.barTintColor
        navigationBar.tintColor = UIColor.tintColor.withAlphaComponent(0.6)
        navigationBar.isTranslucent = false
        
        navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.tintColor
        ]
    }
}