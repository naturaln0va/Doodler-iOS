
import UIKit

extension NSLayoutConstraint {
    
    static func constraints(forPinningViewToSuperview view: UIView) -> [NSLayoutConstraint] {
        var constraints = [NSLayoutConstraint]()
        for idx in 0..<2 {
            constraints.append(contentsOf:
                NSLayoutConstraint.constraints(
                    withVisualFormat: "\(idx == 0 ? "V" : "H"):|[view]|",
                    options: .directionLeadingToTrailing,
                    metrics: nil,
                    views: ["view": view]
                )
            )
        }
        return constraints
    }
    
    static func constraints(forConstrainingView view: UIView, toSize size: CGSize) -> [NSLayoutConstraint] {
        var constraints = [NSLayoutConstraint]()
        for idx in 0..<2 {
            constraints.append(
                NSLayoutConstraint(
                    item: view,
                    attribute: idx == 0 ? .width : .height,
                    relatedBy: .equal,
                    toItem: nil,
                    attribute: .notAnAttribute,
                    multiplier: 1,
                    constant: idx == 0 ? size.width : size.height
                )
            )
        }
        return constraints
    }
    
    static func constraints(forCenteringView view: UIView) -> [NSLayoutConstraint] {
        precondition(view.superview != nil, "View's superview cannot be nil.")
        
        var constraints = [NSLayoutConstraint]()
        for idx in 0..<2 {
            constraints.append(
                NSLayoutConstraint(
                    item: view,
                    attribute: idx == 0 ? .centerX : .centerY,
                    relatedBy: .equal,
                    toItem: view.superview!,
                    attribute: idx == 0 ? .centerX : .centerY,
                    multiplier: 1,
                    constant: 0
                )
            )
        }
        return constraints
    }
    
    static func constraints(with visualFormats: [String], metrics: [String: Any]? = nil, views: [String: Any]) -> [NSLayoutConstraint] {
        var constraints = [NSLayoutConstraint]()
        for format in visualFormats {
            constraints.append(contentsOf:
                NSLayoutConstraint.constraints(
                    withVisualFormat: format,
                    options: .directionLeadingToTrailing,
                    metrics: metrics,
                    views: views
                )
            )
        }
        return constraints
    }
    
}
