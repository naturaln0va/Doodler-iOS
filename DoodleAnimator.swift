
import UIKit

class DoodleAnimator: NSObject {
    
    typealias CompletionBlock = () -> Void
    
    let duration: Double
    var presenting: Bool = false
    var originFrame: CGRect? = nil
    var imageView: UIImageView? = nil
    var dismissCompletionBlock: CompletionBlock?
    
    init(duration: Double, originatingFrame frame: CGRect? = nil, completion: CompletionBlock? = nil) {
        self.duration = duration
        self.originFrame = frame
        self.dismissCompletionBlock = completion
        super.init()
    }
    
}

extension DoodleAnimator: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let fromViewControler = transitionContext.viewController(forKey: .from)
        let toViewControler = transitionContext.viewController(forKey: .to)
        
        let viewToFade = presenting ? toViewControler : fromViewControler
        
        guard let finalVC = viewToFade as? CanvasViewController else {
            print("viewToFade was not of type: 'CanvasViewController'.")
            return
        }
        
        finalVC.view.frame = UIScreen.main.bounds
        containerView.frame = UIScreen.main.bounds
        
        if presenting {
            containerView.addSubview(finalVC.view)
            var animatingImageView: UIImageView? = nil
            finalVC.view.alpha = 0
            
            if let frame = originFrame, let imageView = imageView {
                finalVC.canvas.alpha = 0
                finalVC.strokeSlider.alpha = 0
                
                animatingImageView = UIImageView(frame: frame)
                animatingImageView?.image = imageView.image
                
                containerView.addSubview(animatingImageView!)
            }
            else {
                finalVC.canvas.frame = CGRect(
                    x: finalVC.canvas.bounds.width * 2,
                    y: 0,
                    width: finalVC.canvas.bounds.width,
                    height: finalVC.canvas.bounds.height
                )
            }
            
            UIView.animate(
                withDuration: transitionDuration(using: transitionContext),
                animations: {
                    finalVC.view.alpha = 1
                    animatingImageView?.frame = finalVC.view.frame
                    finalVC.canvas.frame = finalVC.view.frame
                }, completion: { _ in
                    finalVC.canvas.alpha = 1
                    finalVC.strokeSlider.alpha = 1
                    animatingImageView?.removeFromSuperview()
                    transitionContext.completeTransition(true)
                }
            )
            
        }
        else {
            guard let toVC = toViewControler else { return }
            
            toVC.view.frame = UIScreen.main.bounds
            
            containerView.addSubview(toVC.view)
            containerView.addSubview(finalVC.view)
            containerView.bringSubviewToFront(finalVC.view)
            
            UIView.animate(
                withDuration: transitionDuration(using: transitionContext),
                animations: {
                    finalVC.view.alpha = 0.0
                    finalVC.canvas.frame = CGRect(
                        x: -finalVC.canvas.bounds.width,
                        y: 0,
                        width: finalVC.canvas.bounds.width,
                        height: finalVC.canvas.bounds.height
                    )
                },
                completion: { _ in
                    transitionContext.completeTransition(true)
                    self.dismissCompletionBlock?()
            })
        }
    }
    
}
