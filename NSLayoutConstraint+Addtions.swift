
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
    
}
