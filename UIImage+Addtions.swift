
import UIKit

extension UIImage {
    
    func scale(toSize size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 1)
        draw(in: CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    var verticallyFlipped: UIImage? {
        guard let cgImage = cgImage else { return nil }
        let img = UIImage(cgImage: cgImage, scale: 1, orientation: .downMirrored)
        
        guard let imgRef = img.cgImage else { return nil }
        UIGraphicsBeginImageContext(CGSize(width: imgRef.width, height: imgRef.height))
        img.draw(at: .zero)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }
    
}
