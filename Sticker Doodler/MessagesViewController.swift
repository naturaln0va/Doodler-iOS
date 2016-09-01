
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
        
        let vc = DoodleBrowserViewController()
        vc.delegate = self
        controller = vc
        
        for child in childViewControllers {
            child.willMove(toParentViewController: nil)
            child.view.removeFromSuperview()
            child.removeFromParentViewController()
        }
        
        addChildViewController(controller)
        
        controller.view.frame = view.bounds
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controller.view)
        
        controller.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        controller.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        controller.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        controller.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        controller.didMove(toParentViewController: self)
    }
    
}

extension MessagesViewController: DoodleBrowserViewControllerDelegate {
    
    func doodleBrowserViewControllerDidSelectAdd() {
        requestPresentationStyle(.expanded)
    }
    
}
