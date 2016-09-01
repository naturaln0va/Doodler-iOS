
import Foundation

extension URL {
    
    var createdDate: Date? {
        do {
            let values = try resourceValues(forKeys: Set([URLResourceKey.creationDateKey]))
            return values.creationDate
        }
        catch let error {
            print("Error, \(error), reading the creation date of: \(absoluteString)")
        }
        
        return nil
    }
    
}
