//
//  Created by Ryan Ackermann on 8/14/15.
//  Copyright (c) 2015 Ryan Ackermann. All rights reserved.
//

import UIKit

class AutoHideView: UIView
{
    private let animationDuration = 0.25
    private var timer: NSTimer?
    
    func show()
    {
        UIView.animateWithDuration(animationDuration) {
            self.alpha = 1
        }
        
        if let t = timer {
            if t.valid {
                self.timer?.invalidate()
            }
        }
        
        timer = NSTimer.scheduledTimerWithTimeInterval(animationDuration * 2, target: self, selector: "hide", userInfo: nil, repeats: false)
    }
    
    func hide()
    {
        UIView.animateWithDuration(animationDuration) {
            self.alpha = 0
        }
    }

}
