
import UIKit

class StyledNavigationController: UINavigationController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.prefersLargeTitles = true
        
        navigationBar.barTintColor = UIColor.black
        navigationBar.tintColor = UIColor.tintColor.withAlphaComponent(0.6)
        
        let baseTitleAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.tintColor
        ]
        navigationBar.titleTextAttributes = baseTitleAttributes
        navigationBar.largeTitleTextAttributes = baseTitleAttributes
    }
    
}
