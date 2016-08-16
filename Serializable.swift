
import Foundation

protocol Serializable {
    var serializedDictionary: [String: Any] { get }
    init?(serializedDictionary: [String: Any])
}
