
import UIKit

protocol SaturationBrightnessPickerViewDelegate {
    func saturationBrightnessPickerViewDidUpdateColor(_ color: UIColor)
}

class SaturationBrightnessPickerView: UIView, HuePickerViewDelegate {
    
    private let inset: CGFloat = 15
    private let reticuleSize: CGFloat = 25
    var delegate: SaturationBrightnessPickerViewDelegate?
    
    private var hue: CGFloat = 1.0 {
        didSet {
            delegate?.saturationBrightnessPickerViewDidUpdateColor(currentColor)
            setNeedsDisplay()
        }
    }
    
    private var saturation: CGFloat = 0.5 {
        didSet {
            delegate?.saturationBrightnessPickerViewDidUpdateColor(currentColor)
            setNeedsDisplay()
        }
    }
    
    private var brightness: CGFloat = 0.5 {
        didSet {
            delegate?.saturationBrightnessPickerViewDidUpdateColor(currentColor)
            setNeedsDisplay()
        }
    }
    
    var currentColor: UIColor {
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    private func commonInit() {
        clipsToBounds = false
        isOpaque = false
        bounds = bounds.insetBy(dx: -inset, dy: -inset)
    }
    
    func setColorToDisplay(_ color: UIColor) {
        if let comps = color.hsb() {
            hue = comps[0]
            saturation = comps[1]
            brightness = comps[2]
        }
    }
    
    override func draw(_ rect: CGRect) {
        backgroundColor?.setFill()
        UIRectFill(rect)
        
        let rectToDraw = rect.insetBy(dx: inset, dy: inset)
        
        let ctx = UIGraphicsGetCurrentContext()
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        ctx?.saveGState()
        ctx?.clip(to: rectToDraw)
        
        let colors = [UIColor(hue: hue, saturation: 1.0, brightness: 1.0, alpha: 1.0).cgColor,
            UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).cgColor]
        
        let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: [CGFloat(0.0), CGFloat(1.0)])
        ctx?.drawLinearGradient(gradient!, start: CGPoint(x: rectToDraw.size.width, y: 0), end: CGPoint.zero, options: [])
        
        let desaturatedColors = [UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0).cgColor,
            UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0).cgColor]
        
        let desaturatedGradient = CGGradient(colorsSpace: colorSpace, colors: desaturatedColors as CFArray, locations: [CGFloat(0.0), CGFloat(1.0)])
        ctx?.drawLinearGradient(desaturatedGradient!, start: CGPoint.zero, end: CGPoint(x: 0, y: rectToDraw.size.height), options: [])
        
        ctx?.restoreGState()
        
        let adjustedPoint = CGPoint(x: saturation * rectToDraw.width, y: rectToDraw.height - (brightness * rectToDraw.height))
        let reticuleRect = CGRect(x: adjustedPoint.x - (reticuleSize / 2), y: adjustedPoint.y - (reticuleSize / 2), width: reticuleSize, height: reticuleSize)
        
        ctx?.addEllipse(in: reticuleRect)
        ctx?.setFillColor(currentColor.cgColor)
        ctx?.closePath()
        ctx?.drawPath(using: .eoFill)

        ctx?.setLineWidth(1)
        ctx?.setStrokeColor(currentColor.isDarkColor() ? UIColor.white.cgColor : UIColor.black.cgColor)
        ctx?.strokeEllipse(in: reticuleRect)
    }
    
    //MARK: - HuePickerViewDelegate -
    func huePickerViewDidUpdateHue(_ hue: CGFloat) {
        self.hue = hue
    }
    
    //MARK: - Touches -
    private func handleTouches(_ touches: Set<NSObject>) {
        let touch = touches.first as! UITouch
        let point = touch.location(in: self)
        
        let width = bounds.width - (inset * 2)
        let height = bounds.height - (inset * 2)
        
        if point.x < 0 {
            saturation = 0
        }
        else if point.x > width {
            saturation = 1
        }
        else {
            saturation = point.x / width
        }
        
        if point.y < 0 {
            brightness = 1
        }
        else if point.y > height {
            brightness = 0
        }
        else {
            brightness = 1 - (point.y / height)
        }
        
        setNeedsDisplay()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTouches(touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTouches(touches)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTouches(touches)
    }
    
}
