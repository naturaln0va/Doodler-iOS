
import UIKit
import Messages

class MessagesViewController: MSMessagesAppViewController {
    
    override func willBecomeActive(with conversation: MSConversation) {
        super.willBecomeActive(with: conversation)
        
        presentViewController(with: presentationStyle)
    }
    
    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called before the extension transitions to a new presentation style.
        
        presentViewController(with: presentationStyle)
    }
    
    // MARK: Child view controller presentation
    
    private func presentViewController(with presentationStyle: MSMessagesAppPresentationStyle) {
        let controller: UIViewController
        
        if presentationStyle == .expanded {
            let vc = CanvasViewController()
            vc.delegate = self
            vc.shouldInsetLayoutForMessages = true
            controller = vc
        }
        else {
            let vc = DoodleBrowserViewController()
            vc.delegate = self
            controller = vc
        }
        
        for child in childViewControllers {
            child.willMove(toParentViewController: nil)
            child.view.removeFromSuperview()
            child.removeFromParentViewController()
        }
        
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        addChildViewController(controller)
        
        view.addSubview(controller.view)
        view.addConstraints(NSLayoutConstraint.constraints(forPinningViewToSuperview: controller.view))
        
        controller.didMove(toParentViewController: self)
    }
    
}

extension MessagesViewController: CanvasViewControllerDelegate {
    
    func canvasViewControllerDidSaveDoodle() {
        requestPresentationStyle(.compact)
    }
    
    func canvasViewControllerShouldDismiss() {
        requestPresentationStyle(.compact)
    }
    
}

extension MessagesViewController: DoodleBrowserViewControllerDelegate {
    
    func doodleBrowserViewControllerDidSelectAdd() {
        requestPresentationStyle(.expanded)
    }
    
}
