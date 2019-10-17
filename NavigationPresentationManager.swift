
import UIKit

private enum AnimatorConstant {
    static let padding: CGFloat = 20
}

protocol NavigationPresentationConfigurable {
    var contentHeight: CGFloat { get }
}

class NavigationPresentationManager: NSObject {
    
    private let viewController: UIViewController
    private let contentHeight: CGFloat
    
    init<T: UIViewController & NavigationPresentationConfigurable>(viewController: T) {
        self.viewController = viewController
        contentHeight = viewController.contentHeight
        
        super.init()
    }
    
    func present(from parentVC: UIViewController?) {
        let nav = NavigationController(viewController)
        
        nav.transitioningDelegate = self
        nav.modalPresentationStyle = .custom
        
        parentVC?.present(nav, animated: true)
    }
    
}

extension NavigationPresentationManager: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentationController = NavigationPresentationController(presentedViewController: presented, presenting: presenting, contentHeight: contentHeight)
        
        presentationController.delegate = self
        return presentationController
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return NavigationPresentationAnimator(isPresentation: true)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return NavigationPresentationAnimator(isPresentation: false)
    }
    
}

extension NavigationPresentationManager: UIAdaptivePresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
    
}

private class NavigationPresentationAnimator: NSObject {
    
    let isPresentation: Bool
    
    init(isPresentation: Bool) {
        self.isPresentation = isPresentation
        super.init()
    }
    
}

// MARK: - UIViewControllerAnimatedTransitioning

extension NavigationPresentationAnimator: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return isPresentation ? 0.4 : 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let vc = transitionContext.viewController(forKey: isPresentation ? .to : .from) else {
            return
        }
        
        let containerView = transitionContext.containerView
        
        if isPresentation {
            containerView.addSubview(vc.view)
            vc.view.layer.masksToBounds = true
            vc.view.layer.cornerRadius = 9
        }
        
        let presentedFrame = transitionContext.finalFrame(for: vc).centered(in: containerView.frame)

        var dismissedFrame = presentedFrame
        dismissedFrame.origin.y = containerView.frame.size.height

        let animationDuration = transitionDuration(using: transitionContext)
        let initialFrame = isPresentation ? dismissedFrame : presentedFrame
        let finalFrame = isPresentation ? presentedFrame : dismissedFrame
        
        vc.view.frame = initialFrame
        
        UIView.springAnimate(with: animationDuration, animations: {
            vc.view.frame = finalFrame
        }) { finished in
            transitionContext.completeTransition(finished)
        }
    }
}

private class NavigationPresentationController: UIPresentationController {
    
    private var dimmingView: UIView!
    
    private var keyboardFrame: CGRect = .zero
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else {
            return .zero
        }
        
        let childFrameSize = size(
            forChildContentContainer: presentedViewController,
            withParentContainerSize: containerView.bounds.size
        )
        let childFrame = CGRect(origin: .zero, size: childFrameSize)
        
        let finalFrame: CGRect
        
        if keyboardFrame.height > 0 {
            var avoidingKeyboardFrame = childFrame
            avoidingKeyboardFrame.origin.x = AnimatorConstant.padding
            avoidingKeyboardFrame.origin.y = containerView.frame.height - keyboardFrame.height - childFrame.height - AnimatorConstant.padding
            
            finalFrame = avoidingKeyboardFrame
        }
        else {
            var adjustedContainerFrame = containerView.frame
            adjustedContainerFrame.size.height -= keyboardFrame.height
            
            finalFrame = childFrame.centered(in: containerView.frame)
        }
        
        return finalFrame
    }
    
    private let contentHeight: CGFloat
    
    init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?, contentHeight: CGFloat) {
        self.contentHeight = contentHeight
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        
        setUpDimmingView()
        observeKeyboardChanges()
    }
    
    override func presentationTransitionWillBegin() {
        guard let view = containerView else {
            return
        }
        
        dimmingView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(dimmingView, at: 0)
        
        let constraints = [
            dimmingView.topAnchor.constraint(equalTo: view.topAnchor),
            dimmingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dimmingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimmingView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        
        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.alpha = 1.0
            return
        }
        
        coordinator.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 1.0
        })
    }
    
    override func dismissalTransitionWillBegin() {
        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.alpha = 0.0
            return
        }
        
        coordinator.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 0.0
        })
    }
    
    override func containerViewWillLayoutSubviews() {
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
    
    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        return CGSize(width: parentSize.width - (AnimatorConstant.padding * 2), height: contentHeight)
    }
    
    // MARK: - Notifications
    
    private func observeKeyboardChanges() {
        let center = NotificationCenter.default
        
        center.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        center.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrameValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        
        guard let keyboardDurationNumber = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber else {
            return
        }
        
        guard let keyboardCurveNumber = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber else {
            return
        }
        
        keyboardFrame = keyboardFrameValue.cgRectValue
        
        UIView.animate(
            withDuration: keyboardDurationNumber.doubleValue,
            delay: 0,
            options: UIView.AnimationOptions(rawValue: UInt(keyboardCurveNumber.intValue << 16)),
            animations: {
                self.presentedView?.frame = self.frameOfPresentedViewInContainerView
        },
            completion: nil
        )
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let keyboardDurationNumber = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber else {
            return
        }
        
        guard let keyboardCurveNumber = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber else {
            return
        }
        
        keyboardFrame = .zero

        UIView.animate(
            withDuration: keyboardDurationNumber.doubleValue,
            delay: 0,
            options: UIView.AnimationOptions(rawValue: UInt(keyboardCurveNumber.intValue << 16)),
            animations: {
                self.presentedView?.frame = self.frameOfPresentedViewInContainerView
        },
            completion: nil
        )
    }
    
}

// MARK: - Private

private extension NavigationPresentationController {
    
    private func setUpDimmingView() {
        dimmingView = UIView()
        dimmingView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        dimmingView.alpha = 0.0
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        dimmingView.addGestureRecognizer(recognizer)
    }
    
    @objc private func handleTap(recognizer: UITapGestureRecognizer) {
        presentingViewController.dismiss(animated: true)
    }
    
}
