
import UIKit

extension UIViewController {
    
    func setupPopoverInView(sourceView: UIView, inRect rect: CGRect = .zero, barButtonItem: UIBarButtonItem? = nil) {
        modalPresentationStyle = .popover
        popoverPresentationController?.delegate = self
        popoverPresentationController?.backgroundColor = view.backgroundColor
        popoverPresentationController?.barButtonItem = barButtonItem
        popoverPresentationController?.sourceView = sourceView
        popoverPresentationController?.sourceRect = rect
    }
    
}

extension UIViewController: UIPopoverPresentationControllerDelegate {
    
    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
}
