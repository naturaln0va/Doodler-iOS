
import Foundation

class DocumentsController {
    
    static let sharedController = DocumentsController()
    
    private let fileManager = FileManager.default
    private let fileQueue = DispatchQueue(label: "io.ackermann.documents.io")
    private let doodleSavePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
    private let stickerSavePath = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.io.ackermann.doodlesharing")
    private var cachedDoodles: [Doodle]?
    
    func clearCache() {
        cachedDoodles?.removeAll()
        cachedDoodles = nil
    }
    
    func doodles() -> [Doodle] {
        guard let filePath = doodleSavePath else { return [] }
        
        if let doodles = cachedDoodles {
            return doodles
        }
        
        var doodles = [Doodle]()
        
        if let doodleURLs = try? fileManager.contentsOfDirectory(at: filePath, includingPropertiesForKeys: nil, options: []) {
            for url in doodleURLs {
                if let data = try? Data(contentsOf: url, options: []) {
                    if let dataDict = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String: Any] {
                        if let doodle = Doodle(serializedDictionary: dataDict) {
                            doodles.append(doodle)
                        }
                    }
                }
            }
            cachedDoodles = doodles
        }
        
        return doodles
    }
    
    func stickerURLs() -> [URL] {
        guard let filePath = stickerSavePath else { return [] }
        
        var urls = [URL]()
        
        if let fileURLs = try? fileManager.contentsOfDirectory(at: filePath, includingPropertiesForKeys: nil, options: []) {
            urls.append(contentsOf: fileURLs)
        }
        
        return urls
    }
    
    func save(doodle: Doodle, completion: @escaping (Bool) -> Void) {
        guard let savePath = doodleSavePath else { return }
        var fullFilePath = savePath
        fullFilePath.appendPathComponent(doodle.fileName)
        
        var doodleToSave = doodle
        doodleToSave.updatedDate = Date()
        
        fileQueue.async {
            do {
                try NSKeyedArchiver.archivedData(withRootObject: doodleToSave.serializedDictionary).write(to: fullFilePath)
            }
            catch let error {
                print("Error saving file to path: \(fullFilePath)\nError: \(error)")
                DispatchQueue.main.async { completion(false) }
                return
            }
            
            if let stickerSavePath = self.stickerSavePath {
                let fullStickerSavePath = stickerSavePath.appendingPathComponent(doodle.stickerFileName)
                
                do {
                    try doodle.stickerImageData.write(to: fullStickerSavePath, options: .atomic)
                }
                catch let error {
                    print("Error saving sticker to path: \(fullStickerSavePath)\nError: \(error)")
                }
            }
            
            if let index = self.cachedDoodles?.index(of: doodle) {
                self.cachedDoodles?.remove(at: index)
            }
            
            self.cachedDoodles?.append(doodle)
            DispatchQueue.main.async { completion(true) }
        }
    }
    
    func delete(doodle: Doodle, completion: @escaping (Bool) -> Void) {
        guard let savePath = doodleSavePath else { return }
        var fullFilePath = savePath
        fullFilePath.appendPathComponent(doodle.fileName)
        
        fileQueue.async {
            do {
                try self.fileManager.removeItem(at: fullFilePath)
            }
            catch {
                print("Error deleting file at path: \(fullFilePath)\nError: \(error)")
                DispatchQueue.main.async { completion(false) }
                return
            }
            
            if let stickerSavePath = self.stickerSavePath {
                let fullStickerSavePath = stickerSavePath.appendingPathComponent(doodle.stickerFileName)
                
                do {
                    try self.fileManager.removeItem(at: fullStickerSavePath)
                }
                catch let error {
                    print("Error deleting sticker at path: \(fullStickerSavePath)\nError: \(error)")
                }
            }
            
            if let index = self.cachedDoodles?.index(of: doodle) {
                self.cachedDoodles?.remove(at: index)
            }
            
            DispatchQueue.main.async { completion(true) }
        }
    }
    
}
