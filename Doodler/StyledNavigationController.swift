
import UIKit

class StyledNavigationController: UINavigationController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.barTintColor = UIColor.black
        navigationBar.tintColor = UIColor.tintColor.withAlphaComponent(0.6)
        
        navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.tintColor
        ]
    }
    
}
