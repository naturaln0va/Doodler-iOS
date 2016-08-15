
import Foundation

protocol Serializable {
    var serializedDictionary: [NSObject: AnyObject] { get }
    init?(serializedDictionary: [NSObject: AnyObject])
}
