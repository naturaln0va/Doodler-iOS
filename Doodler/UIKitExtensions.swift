
import UIKit

func delay(_ delay: Double, closure: ()->()) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),
        execute: closure
    )
}

func isIPad() -> Bool {
    return UIDevice.current.userInterfaceIdiom == .pad
}
