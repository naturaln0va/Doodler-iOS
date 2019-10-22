
import UIKit

struct Doodle {
    
    let createdDate: Date
    var updatedDate: Date
    let history: History
    let stickerImageData: Data
    let previewImage: UIImage
    
    private var baseFileName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy+HH.mm.ss"
        
        return formatter.string(from: createdDate)
    }
    
    var fileName: String {
        return baseFileName + ".doodle"
    }
    
    var stickerFileName: String {
        return baseFileName + ".png"
    }
    
    var size: CGSize {
        return previewImage.size
    }
    
}

extension Doodle: Equatable {
    
    static func ==(lhs: Doodle, rhs: Doodle) -> Bool {
        return lhs.fileName == rhs.fileName
    }
    
}

extension Doodle: Serializable {
    
    var serializedDictionary: [String : Any] {
        return [
            "created": createdDate,
            "updated": updatedDate,
            "history": history.serializedDictionary,
            "sticker": stickerImageData,
            "preview": previewImage
        ]
    }
    
    init?(serializedDictionary: [String : Any]) {
        guard let createdDate = serializedDictionary["created"] as? Date,
            let updatedDate = serializedDictionary["updated"] as? Date,
            let historyDict = serializedDictionary["history"] as? [String : AnyObject],
            let stickerImageData = serializedDictionary["sticker"] as? Data,
            let previewImage = serializedDictionary["preview"] as? UIImage else {
                return nil
        }
        
        guard let history = History(serializedDictionary: historyDict) else { return nil }
        
        self.createdDate = createdDate
        self.updatedDate = updatedDate
        self.history = history
        self.stickerImageData = stickerImageData
        self.previewImage = previewImage
    }
    
}
