
import UIKit

class StyledNavigationController: UINavigationController
{

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.barTintColor = UIColor.barMainColor
        navigationBar.tintColor = UIColor.barTintColor
        navigationBar.isTranslucent = false
        
        navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.barTintColor
        ]
    }
}
