
import UIKit

extension UIImage {
    
    private var croppedImageRect: CGRect {
        var minX = 0
        var maxX = 0
        var minY = 0
        var maxY = 0
        
        let pixelData = self.cgImage?.dataProvider?.data ?? Data() as CFData
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        let threshold = 0.975
        
        for x in 0..<Int(size.width) {
            for y in 0..<Int(size.height) {
                let pixelInfo: Int = ((Int(size.width) * Int(y)) + Int(x)) * 4
                
                let r = Double(data[pixelInfo]) / 255.0
                let g = Double(data[pixelInfo + 1]) / 255.0
                let b = Double(data[pixelInfo + 2]) / 255.0
                
                if r < threshold && g < threshold && b < threshold {
                    minX = x
                    break
                }
            }
            if minX > 0 {
                break
            }
        }
        
        for y in 0..<Int(size.height) {
            for x in 0..<Int(size.width) {
                let pixelInfo: Int = ((Int(size.width) * Int(y)) + Int(x)) * 4
                
                let r = Double(data[pixelInfo]) / 255.0
                let g = Double(data[pixelInfo + 1]) / 255.0
                let b = Double(data[pixelInfo + 2]) / 255.0
                
                if r < threshold && g < threshold && b < threshold {
                    minY = y
                    break
                }
            }
            if minY > 0 {
                break
            }
        }
        
        for x in 0..<Int(size.width) {
            for y in 0..<Int(size.height) {
                let adjustedXValue = (Int(size.width) - 1) - x
                let pixelInfo: Int = ((Int(size.width) * Int(y)) + Int(adjustedXValue)) * 4
                
                let r = Double(data[pixelInfo]) / 255.0
                let g = Double(data[pixelInfo + 1]) / 255.0
                let b = Double(data[pixelInfo + 2]) / 255.0
                
                if r < threshold && g < threshold && b < threshold {
                    maxX = adjustedXValue
                    break
                }
            }
            if maxX > 0 {
                break
            }
        }
        
        for y in 0..<Int(size.height) {
            for x in 0..<Int(size.width) {
                let adjustedYValue = (Int(size.height) - 1) - y
                let pixelInfo: Int = ((Int(size.width) * Int(adjustedYValue)) + Int(x)) * 4
                
                let r = Double(data[pixelInfo]) / 255.0
                let g = Double(data[pixelInfo + 1]) / 255.0
                let b = Double(data[pixelInfo + 2]) / 255.0
                
                if r < threshold && g < threshold && b < threshold {
                    maxY = adjustedYValue
                    break
                }
            }
            if maxY > 0 {
                break
            }
        }
        
        let topLeftPoint = CGPoint(x: minX, y: minY)
        let bottomRightPoint = CGPoint(x: maxX, y: maxY)
        
        let croppedSize = CGSize(
            width: (bottomRightPoint.x - topLeftPoint.x) + 1,
            height: (bottomRightPoint.y - topLeftPoint.y) + 1
        )
        
        return CGRect(origin: topLeftPoint, size: croppedSize)
    }
    
    var autoCroppedImage: UIImage? {
        guard let imgRef = cgImage?.cropping(to: croppedImageRect) else { return nil }
        return UIImage(cgImage: imgRef)
    }
    
}
