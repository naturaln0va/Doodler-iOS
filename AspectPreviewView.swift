
import UIKit

class AspectPreviewView: UIView {
    
    var aspectRatio: CGFloat = 0.67 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initComplete()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        initComplete()
    }
    
    private func initComplete() {
        layer.needsDisplayOnBoundsChange = true
    }
    
    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else {
            return
        }
        
        let paddedRect = rect.insetBy(dx: 4, dy: 4)
        let minSide = min(paddedRect.width, paddedRect.height)
        
        let pathFrame: CGRect
        
        if aspectRatio > 1 { // landscape
            let aspectSide = minSide / aspectRatio
            let centeredRemainder = 4 + (abs(minSide - aspectSide) / 2)
            pathFrame = CGRect(x: 4, y: centeredRemainder, width: minSide, height: aspectSide)
        }
        else {
            let aspectSide = minSide * aspectRatio
            let centeredRemainder = 4 + (abs(minSide - aspectSide) / 2)
            pathFrame = CGRect(x: centeredRemainder, y: 4, width: aspectSide, height: minSide)
        }
        
        let path = UIBezierPath(roundedRect: pathFrame, cornerRadius: 3)
        
        ctx.setStrokeColor(UIColor(white: 0.375, alpha: 1).cgColor)
        ctx.setFillColor(UIColor(white: 0.98, alpha: 1).cgColor)
        
        ctx.addPath(path.cgPath)
        ctx.fillPath()
        
        ctx.addPath(path.cgPath)
        ctx.setLineWidth(2)
        ctx.strokePath()
    }
        
}
