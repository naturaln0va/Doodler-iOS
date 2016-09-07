
import UIKit

extension CGImage {
        
    var autoCroppedImage: UIImage? {
        var minX = 0
        var maxX = 0
        var minY = 0
        var maxY = 0
        
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
        
        adjustedImageRef.draw(self, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        let pixelData = adjustedImageRef.makeImage()?.dataProvider?.data ?? Data() as CFData
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)

        let threshold: UInt8 = 95
        
        print("Alpha information: \(alphaInfo.rawValue)")
        print("Bitmap information: \(bitmapInfo)")
        
        for x in 0..<Int(width) {
            for y in 0..<Int(height) {
                let pixelInfo: Int = ((Int(width) * Int(y)) + Int(x)) * 4
                
                let r = data[pixelInfo + 0]
                let g = data[pixelInfo + 1]
                let b = data[pixelInfo + 2]
                let a = data[pixelInfo + 3]
                
                if a > threshold {
                    minX = x
                    print("min x: \(x). RGBA: \(r),\(g),\(b),\(a)")
                    break
                }
            }
            if minX > 0 {
                break
            }
        }
        
        for y in 0..<Int(height) {
            for x in 0..<Int(width) {
                let pixelInfo: Int = ((Int(width) * Int(y)) + Int(x)) * 4
                
                let r = data[pixelInfo + 0]
                let g = data[pixelInfo + 1]
                let b = data[pixelInfo + 2]
                let a = data[pixelInfo + 3]
                
                if a > threshold {
                    minY = y
                    print("min y: \(y). RGBA: \(r),\(g),\(b),\(a)")
                    break
                }
            }
            if minY > 0 {
                break
            }
        }
        
        for x in 0..<Int(width) {
            for y in 0..<Int(height) {
                let adjustedXValue = (Int(width) - 1) - x
                let pixelInfo: Int = ((Int(width) * Int(y)) + Int(adjustedXValue)) * 4
                
                let r = data[pixelInfo + 0]
                let g = data[pixelInfo + 1]
                let b = data[pixelInfo + 2]
                let a = data[pixelInfo + 3]
                
                if a > threshold {
                    maxX = adjustedXValue
                    print("max x: \(adjustedXValue). RGBA: \(r),\(g),\(b),\(a)")
                    break
                }
            }
            if maxX > 0 {
                break
            }
        }
        
        for y in 0..<Int(height) {
            for x in 0..<Int(width) {
                let adjustedYValue = (Int(height) - 1) - y
                let pixelInfo: Int = ((Int(width) * Int(adjustedYValue)) + Int(x)) * 4
                
                let r = data[pixelInfo + 0]
                let g = data[pixelInfo + 1]
                let b = data[pixelInfo + 2]
                let a = data[pixelInfo + 3]
                
                if a > threshold {
                    maxY = adjustedYValue
                    print("max y: \(adjustedYValue). RGBA: \(r),\(g),\(b),\(a)")
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
        
        guard let imgRef = cropping(to: CGRect(origin: topLeftPoint, size: croppedSize)) else { return nil }
        
        let maxSideLength: CGFloat = 285
        let largerSide = max(croppedSize.width, croppedSize.height)
        let ratioScale = largerSide > maxSideLength ? largerSide / maxSideLength : 1
        let newSize = CGSize(width: croppedSize.width / ratioScale, height: croppedSize.height / ratioScale)
        
        print("new size: \(newSize)")
        
        guard let croppedImage = UIImage(cgImage: imgRef).scale(toSize: newSize) else { return nil }
        
        let stickerSize = CGSize(width: maxSideLength, height: maxSideLength)
        UIGraphicsBeginImageContextWithOptions(stickerSize, false, 1)
        
        croppedImage.draw(at:
            CGPoint(
                x: (stickerSize.width - croppedImage.size.width) / 2,
                y: (stickerSize.height - croppedImage.size.height) / 2
            )
        )
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        print("final image size: \(image?.size)")
        
        return image
    }
    
}
