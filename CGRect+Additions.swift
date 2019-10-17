
import CoreGraphics

extension CGRect {
    
    func centered(in rect: CGRect) -> CGRect {
        return CGRect(
            x: (rect.width / 2) - (width / 2),
            y: (rect.height / 2) - (height / 2),
            width: width,
            height: height
        )
    }
    
}
