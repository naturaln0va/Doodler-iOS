
import UIKit

class GridView: UIView {

    override func draw(_ rect: CGRect) {
        let width: CGFloat = bounds.width
        let height: CGFloat = bounds.height
        let spaceBetween: CGFloat = 18.0
        let ctx = UIGraphicsGetCurrentContext()
        
        ctx?.setLineWidth(1.0)
        ctx?.setStrokeColor(UIColor(white: 1.0, alpha: 0.075).cgColor)
        ctx?.setFillColor(UIColor(white: 0.15, alpha: 1.0).cgColor)
        
        ctx?.fill(bounds)
        
        for x in 0..<Int(width) {
            for y in 0..<Int(height) {
                ctx?.moveTo(x: CGFloat(x) * spaceBetween, y: CGFloat(y) * spaceBetween)
                ctx?.addLineTo(x: max((CGFloat(x) * spaceBetween) + width, width), y: CGFloat(y) * spaceBetween)
                
                ctx?.moveTo(x: CGFloat(x) * spaceBetween, y: CGFloat(y) * spaceBetween)
                ctx?.addLineTo(x: CGFloat(x) * spaceBetween, y: max((CGFloat(y) * spaceBetween) + height, height))
            }
        }
        
        ctx?.strokePath()
    }
    
}
