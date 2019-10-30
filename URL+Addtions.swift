
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
    
    func regularFileAllocatedSize() throws -> UInt64 {
        let allocatedSizeResourceKeys: Set<URLResourceKey> = [
            .isRegularFileKey,
            .fileAllocatedSizeKey,
            .totalFileAllocatedSizeKey,
        ]
        
        let resourceValues = try self.resourceValues(forKeys: allocatedSizeResourceKeys)

        // We only look at regular files.
        guard resourceValues.isRegularFile ?? false else {
            return 0
        }

        // To get the file's size we first try the most comprehensive value in terms of what
        // the file may use on disk. This includes metadata, compression (on file system
        // level) and block size.
        // In case totalFileAllocatedSize is unavailable we use the fallback value (excluding
        // meta data and compression) This value should always be available.
        return UInt64(resourceValues.totalFileAllocatedSize ?? resourceValues.fileAllocatedSize ?? 0)
    }

}
