
import UIKit

extension UIColor {
    
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let red = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hex & 0xFF00) >> 8) / 255.0
        let blue = CGFloat(hex & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha);
    }
    
    var hexString: String? {
        var redValue: CGFloat = 0
        var greenValue: CGFloat = 0
        var blueValue: CGFloat = 0
        var alphaValue: CGFloat = 0
        
        if self.getRed(&redValue, green: &greenValue, blue: &blueValue, alpha: &alphaValue) {
            let r = Int(redValue * 255.0)
            let g = Int(greenValue * 255.0)
            let b = Int(blueValue * 255.0)
            
            return "#"+String(format: "%02X", Int(r))+String(format: "%02X", Int(g))+String(format: "%02X", Int(b))
        }
        else {
            return nil
        }
    }
    
    func rgb() -> [Float]? {
        var fRed: CGFloat = 0
        var fGreen: CGFloat = 0
        var fBlue: CGFloat = 0
        var fAlpha: CGFloat = 0
        if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            return [Float(fRed), Float(fGreen), Float(fBlue)]
        }
        else {
            return nil
        }
    }
    
    func hsb() -> [CGFloat]? {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        if self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            return [hue, saturation, brightness, alpha]
        }
        else {
            return nil
        }
    }
    
    func isDarkColor() -> Bool {
        return (hsb()?[2] ?? 0) < CGFloat(0.675)
    }
    
    var redValue: CGFloat {
        return CGFloat(rgb()?[0] ?? 0)
    }
    
    var greenValue: CGFloat {
        return CGFloat(rgb()?[1] ?? 0)
    }
    
    var blueValue: CGFloat {
        return CGFloat(rgb()?[2] ?? 0)
    }
    
    static var barTintColor: UIColor {
        return UIColor(white: 0.2, alpha: 1.0)
    }
    
    static var tintColor: UIColor {
        return UIColor(hex: 0xe5e5e5)
    }
    
    static var backgroundColor: UIColor {
        return UIColor(white: 0.185, alpha: 1.0)
    }
    
    static var doodlerRed: UIColor {
        return UIColor(red: 0.898, green: 0.078, blue: 0.078, alpha: 1)
    }

}
