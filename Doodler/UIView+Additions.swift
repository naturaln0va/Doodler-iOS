
import UIKit

extension UIView {
    
    /**
     Captures the screen and returns a UIImage with its contents.
     */
    var imageByCapturing: UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0.0)
        
        drawHierarchy(in: CGRect(x: 0.0, y: 0.0, width: bounds.size.width, height: bounds.size.height), afterScreenUpdates: false)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    /**
     Shows a rectangle around the view's frame.
     
     - Parameter color: The border color.
     */
    @objc(showBoundingRectWithColor:)
    func showBoundingRect(with color: UIColor = .red) {
        layer.borderColor = color.cgColor
        layer.borderWidth = 1
    }

}
