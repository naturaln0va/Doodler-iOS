
import Foundation

class DocumentsController {
    
    static let sharedController = DocumentsController()
    
    private let fileManager = FileManager.default
    private let fileQueue = DispatchQueue(label: "io.ackermann.documents.io")
    private let doodleSavePath: URL? = {
        guard let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.io.ackermann.doodlesharing") else {
            print("Failed to create the doodle documents directory.")
            return nil
        }
        
        var wholeURL = url
        
        wholeURL.appendPathComponent("/doodles")
        
        if !FileManager.default.fileExists(atPath: url.absoluteString) {
            do {
                try FileManager.default.createDirectory(at: wholeURL, withIntermediateDirectories: false, attributes: nil)
            }
            catch let error as NSError {
                if error.code == 516 {
                    return wholeURL
                }
                
                print("Error creating the doodle documents directory. Error: \(error)")
                return nil
            }
        }
        
        return wholeURL
    }()
    private let stickerSavePath: URL? = {
        guard let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.io.ackermann.doodlesharing") else {
            print("Failed to create the doodle documents directory.")
            return nil
        }
        
        var wholeURL = url
        
        wholeURL.appendPathComponent("/stickers")
        
        if !FileManager.default.fileExists(atPath: url.absoluteString) {
            do {
                try FileManager.default.createDirectory(at: wholeURL, withIntermediateDirectories: false, attributes: nil)
            }
            catch let error as NSError {
                if error.code == 516 {
                    return wholeURL
                }
                
                print("Error creating the doodle documents directory. Error: \(error)")
                return nil
            }
        }
        
        return wholeURL
    }()
    
    var doodles: [Doodle] {
        guard let filePath = doodleSavePath else { return [] }
        
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
        }
        
        return doodles
    }
    
    var stickerURLs: [URL] {
        guard let filePath = stickerSavePath else { return [] }
        
        var urls = [URL]()
        
        if let fileURLs = try? fileManager.contentsOfDirectory(at: filePath, includingPropertiesForKeys: nil, options: []) {
            urls.append(contentsOf: fileURLs)
        }
        
        return urls
    }
    
    func save(doodle: Doodle, completion: ((Bool) -> Void)?) {
        guard let savePath = doodleSavePath else {
            DispatchQueue.main.async { completion?(false) }
            return
        }
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
                DispatchQueue.main.async { completion?(false) }
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
            
            DispatchQueue.main.async { completion?(true) }
        }
    }
    
    func delete(doodles: [Doodle], completion: ((Bool) -> Void)?) {
        guard let savePath = doodleSavePath else {
            DispatchQueue.main.async { completion?(false) }
            return
        }
        
        for doodle in doodles {
            let fullFilePath = savePath.appendingPathComponent(doodle.fileName)
            
            fileQueue.async {
                do {
                    try self.fileManager.removeItem(at: fullFilePath)
                }
                catch {
                    print("Error deleting file at path: \(fullFilePath)\nError: \(error)")
                    DispatchQueue.main.async { completion?(false) }
                    return
                }
                
                if let stickerSavePath = self.stickerSavePath {
                    let fullStickerSavePath = stickerSavePath.appendingPathComponent(doodle.stickerFileName)
                    
                    do {
                        try self.fileManager.removeItem(at: fullStickerSavePath)
                    }
                    catch let error {
                        print("Error deleting sticker at path: \(fullStickerSavePath)\nError: \(error)")
                        DispatchQueue.main.async { completion?(false) }
                        return
                    }
                }
                
                DispatchQueue.main.async { completion?(true) }
            }
        }
    }
    
}
