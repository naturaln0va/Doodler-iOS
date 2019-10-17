
import UIKit
import Messages

class MessagesViewController: MSMessagesAppViewController {
    
    override func willBecomeActive(with conversation: MSConversation) {
        super.willBecomeActive(with: conversation)
        
        presentViewController(with: presentationStyle)
    }
    
    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        presentViewController(with: presentationStyle)
    }
    
    // MARK: Child view controller presentation
    
    private func presentViewController(with presentationStyle: MSMessagesAppPresentationStyle) {
        let controller: UIViewController
        
        if presentationStyle == .expanded {
            let vc = CanvasViewController(size: view.bounds.size)
            vc.delegate = self
            vc.isPresentingWithinMessages = true
            controller = vc
        }
        else {
            let vc = DoodleBrowserViewController()
            vc.delegate = self
            controller = vc
        }
        
        for child in children {
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }
        
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        addChild(controller)
        
        view.addSubview(controller.view)
        view.addConstraints(NSLayoutConstraint.constraints(forPinningViewToSuperview: controller.view))
        
        controller.didMove(toParent: self)
    }
    
}

extension MessagesViewController: CanvasViewControllerDelegate {
    
    func canvasViewControllerShouldDismiss(_ vc: CanvasViewController, didSave: Bool) {
        requestPresentationStyle(.compact)
    }
    
}

extension MessagesViewController: DoodleBrowserViewControllerDelegate {
    
    func doodleBrowserViewControllerDidSelectAdd() {
        requestPresentationStyle(.expanded)
    }
    
}
