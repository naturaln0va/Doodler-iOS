
import Foundation


extension NSCharacterSet {
    
    static func hexadecimalCharacterSet() -> NSCharacterSet {
        return NSCharacterSet(charactersInString: "0123456789aAbBcCdDeEfF")
    }
    
}