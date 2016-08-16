
import Foundation

class DocumentsController {
    
    static let sharedController = DocumentsController()
    
    private let fileManager = FileManager.default
    private let doodleSavePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy+HH.mm"
        return formatter
    }()
    
    func doodles() -> [Doodle] {
        guard let savePath = doodleSavePath else { return [] }
        
        var doodles = [Doodle]()
        if let doodleURLs = try? fileManager.contentsOfDirectory(at: savePath, includingPropertiesForKeys: nil, options: []) {
            for url in doodleURLs {
                if let data = try? Data(contentsOf: url, options: []) {
                    if let dataDict = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String: Any] {
                        if let doodle = Doodle(serializedDictionary: dataDict) {
                            doodles.append(doodle)
                        }
                    }
                }
            }
        }
        
        return doodles
    }
    
    func save(doodle: Doodle) {
        guard let savePath = doodleSavePath else { return }
        var fullSavePath = savePath
        fullSavePath.appendPathComponent("d\(dateFormatter.string(from: doodle.date)).doodle")
        
        do {
            try NSKeyedArchiver.archivedData(withRootObject: doodle.serializedDictionary).write(to: fullSavePath)
        }
        catch let error {
            print("Error saving file to path: \(fullSavePath)\nError: \(error)")
        }
    }
    
}
