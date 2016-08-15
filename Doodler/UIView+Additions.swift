
import UIKit

extension UIView {
    
    var imageByCapturing: UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0.0)
        
        drawHierarchy(in: CGRect(x: 0.0, y: 0.0, width: bounds.size.width, height: bounds.size.height), afterScreenUpdates: false)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image!
    }
    
}
