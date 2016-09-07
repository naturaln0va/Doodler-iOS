
import UIKit

class GridView: UIView {

    override func draw(_ rect: CGRect) {
        UIColor.backgroundColor.setFill()
        UIRectFill(rect)
        
        let drawSize = CGSize(width: 18, height: 18)
        UIGraphicsBeginImageContext(drawSize)
        let path = UIBezierPath()
        
        path.move(to: CGPoint(x: drawSize.width / 2, y: 0))
        path.addLine(to: CGPoint(x: drawSize.width / 2, y: drawSize.height))

        path.move(to: CGPoint(x: 0, y: drawSize.height / 2))
        path.addLine(to: CGPoint(x: drawSize.width, y: drawSize.height / 2))
        
        UIColor(white: 1, alpha: 0.075).setStroke()
        path.stroke()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if let image = image {
            UIColor(patternImage: image).setFill()
            UIGraphicsGetCurrentContext()?.fill(rect)
        }
    }
    
}
