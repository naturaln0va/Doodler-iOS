
import UIKit

protocol HuePickerViewDelegate {
    func huePickerViewDidUpdateHue(_ hue: CGFloat)
}

class HuePickerView: UIView {
    
    private let step: CGFloat = 0.166666666666667
    private let hueIndicatorSize: CGFloat = 5
    var delegate: HuePickerViewDelegate?
    
    var hue: CGFloat = 0.5 {
        didSet {
            delegate?.huePickerViewDidUpdateHue(self.hue)
            setNeedsDisplay()
        }
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
        clipsToBounds = true
    }

    override func draw(_ rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let locations = [CGFloat(0.0), step, step * 2, step * 3, step * 4, step * 5, CGFloat(1.0)]
        
        let colors = [
            UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0).cgColor,
            UIColor(red: 1.0, green: 0.0, blue: 1.0, alpha: 1.0).cgColor,
            UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0).cgColor,
            UIColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0).cgColor,
            UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0).cgColor,
            UIColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0).cgColor,
            UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0).cgColor
        ] as CFArray
        
        ctx?.saveGState()
        
        ctx?.clip(to: CGRect(x: 0, y: 0, width: rect.width, height: 8))
        
        let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: locations)
        ctx?.drawLinearGradient(gradient!, start: CGPoint(x: rect.width, y: 0), end: CGPoint.zero, options: [])
        
        ctx?.restoreGState()
        
        let adjustedPosition = CGFloat(rect.width) * hue
        
        ctx?.addRect(CGRect(x: adjustedPosition - (hueIndicatorSize / 2), y: 0, width: hueIndicatorSize, height: rect.height))
        ctx?.setFillColor(UIColor.white.cgColor)
        ctx?.setShadow(offset: CGSize.zero, blur: 2, color: UIColor.black.cgColor)
        ctx?.closePath()
        ctx?.drawPath(using: .fill)
    }
    
    //MARK: - Touches -
    private func handleTouches(_ touches: Set<NSObject>) {
        let touch = touches.first as! UITouch
        let point = touch.location(in: self)
        
        if point.x < 0 {
            hue = 0
        }
        else if point.x > bounds.width {
            hue = 1
        }
        else {
            hue = point.x / bounds.width
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
