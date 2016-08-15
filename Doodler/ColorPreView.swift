
import UIKit

class ColorPreView: UIView {
    
    var previousColor: UIColor? {
        didSet {
            setNeedsDisplay()
        }
    }
    var newColor: UIColor? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect)
    {
        let ctx = UIGraphicsGetCurrentContext()
        
        if let previous = previousColor {
            previous.set()
            ctx?.fill(CGRect(x: 0, y: 0, width: rect.width / 2, height: rect.height))
        }
        
        if let new = newColor {
            new.set()
            ctx?.fill(CGRect(x: rect.width / 2, y: 0, width: rect.width / 2, height: rect.height))
        }
    }
    
}
