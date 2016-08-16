
import UIKit

class StrokeSizeView: AutoHideView {

    var strokeSize: CGFloat? {
        didSet {
            setNeedsDisplay()
            show()
        }
    }
    
    override func show() {
        UIView.animate(withDuration: animationDuration) {
            self.alpha = 0.675
        }
        
        if let t = timer {
            if t.isValid {
                timer?.invalidate()
            }
        }
        
        timer = Timer.scheduledTimer(
            timeInterval: animationDuration * 2,
            target: self,
            selector: #selector(StrokeSizeView.hide),
            userInfo: nil,
            repeats: false
        )
    }
    
    override func draw(_ rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        
        UIColor(hex: 0x262626).set()
        UIRectFill(rect)
        
        if let size = strokeSize {
            ctx?.setLineCap(.round)
            ctx?.setStrokeColor(UIColor.white.cgColor)
            ctx?.setLineWidth(size)
            
            let path = CGMutablePath()
            let xPos = rect.midX
            let yPos = rect.midY
            
            path.move(to: CGPoint(x: xPos, y: yPos))
            path.addLine(to: CGPoint(x: xPos, y: yPos))
            
            ctx?.addPath(path)
            ctx?.strokePath()
        }
    }
}
