
import UIKit

extension UIImage {
    
    func imageByTintingWithColor(color: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        color.setFill()
        
        let bounds = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIRectFill(bounds)
        draw(in: bounds, blendMode: .destinationIn, alpha: 1)
        
        let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
        return tintedImage
    }
    
    func color(at position: CGPoint) -> UIColor? {
        guard let cgImage = cgImage else { return nil }
        
        let width = Int(size.width)
        let height = Int(size.height)
        
        let adjustedRGBABitmapContext = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )
        
        guard let adjustedImageRef = adjustedRGBABitmapContext else {
            return nil
        }
        
        adjustedImageRef.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        let pixelData = adjustedImageRef.makeImage()?.dataProvider?.data ?? Data() as CFData
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        let pixelInfo: Int = ((Int(width) * Int(position.y)) + Int(position.x)) * 4
        
        let r = CGFloat(data[pixelInfo + 0]) / 255
        let g = CGFloat(data[pixelInfo + 1]) / 255
        let b = CGFloat(data[pixelInfo + 2]) / 255
        let a = CGFloat(data[pixelInfo + 3]) / 255
        
        if a == 0 { return nil }
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    
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
