
import UIKit

class ColorPreviewButton: UIView {
    
    var color: UIColor? {
        didSet {
            guard let color = color else { return }
            
            if color.isDarkColor() {
                layer.borderColor = UIColor.white.cgColor
                layer.borderWidth = 1
                layer.cornerRadius = bounds.width / 2
                layer.masksToBounds = layer.cornerRadius > 0
            }
            else {
                layer.borderColor = UIColor.clear.cgColor
                layer.borderWidth = 0
                layer.cornerRadius = bounds.width / 2
                layer.masksToBounds = layer.cornerRadius > 0
            }
            
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        color?.set()
        UIGraphicsGetCurrentContext()?.fillEllipse(in: rect)
    }
    
}
