
import UIKit

class ColorPreviewButton: UIView {
    
    var color: UIColor? {
        didSet {
            if self.color!.isDarkColor() {
                layer.borderColor = UIColor.white.cgColor
                layer.borderWidth = 1
                layer.cornerRadius = bounds.width / 2
            }
            else {
                layer.borderColor = UIColor.clear.cgColor
                layer.borderWidth = 0
                layer.cornerRadius = bounds.width / 2
            }
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        UIColor(hex: 0x141414).set()
        UIRectFill(rect)
        
        color?.set()
        ctx?.fillEllipse(in: rect)
    }
    
}
