
import UIKit

extension UIViewController {
    
    func setupPopoverInView(sourceView: UIView, inRect rect: CGRect = CGRect.zero, barButtonItem: UIBarButtonItem? = nil) {
        let popoverViewController = popoverPresentationController
        popoverViewController?.backgroundColor = view.backgroundColor
        popoverViewController?.barButtonItem = barButtonItem
        popoverViewController?.sourceView = sourceView
        popoverViewController?.sourceRect = rect
    }
    
}
