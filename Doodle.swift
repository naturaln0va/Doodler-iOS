
import UIKit

struct Doodle {
    
    let date: Date
    let image: UIImage
    let history: History
    
}

extension Doodle: Serializable {
    
    var serializedDictionary: [String : Any] {
        return [
            "date": date,
            "image": image,
            "history": history.serializedDictionary
        ]
    }
    
    init?(serializedDictionary: [String : Any]) {
        guard let date = serializedDictionary["date"] as? Date,
            let image = serializedDictionary["image"] as? UIImage,
            let historyDict = serializedDictionary["history"] as? [String : AnyObject] else {
                return nil
        }
        
        guard let history = History(serializedDictionary: historyDict) else { return nil }
        
        self.date = date
        self.image = image
        self.history = history
    }
    
}
