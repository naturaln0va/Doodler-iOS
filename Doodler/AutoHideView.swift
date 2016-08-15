
import UIKit

class AutoHideView: UIView {
    
    let animationDuration = 0.25
    var timer: Timer?
    
    func show() {
        UIView.animate(withDuration: animationDuration) {
            self.alpha = 1
        }
        
        if let t = timer {
            if t.isValid {
                timer?.invalidate()
            }
        }
        
        timer = Timer.scheduledTimer(timeInterval: animationDuration * 2, target: self, selector: #selector(AutoHideView.hide), userInfo: nil, repeats: false)
    }
    
    func hide() {
        UIView.animate(withDuration: animationDuration) {
            self.alpha = 0
        }
    }

}
