
import UIKit

struct History {
    
    private let sizeLimit = 25
    private var undoList = [CGImage]()
    private var redoList = [CGImage]()
    
    var lastImage: CGImage? {
        return undoList.last
    }
    
    var canUndo: Bool {
        return !undoList.isEmpty
    }
    
    var canRedo: Bool {
        return !redoList.isEmpty
    }
    
    var canReset: Bool {
        return canUndo || canRedo
    }
    
    // MARK: - Private
    private mutating func appendUndo(image: CGImage?) {
        guard let image = image else { return }
        
        if undoList.count >= sizeLimit {
            undoList.removeFirst()
        }
        
        undoList.append(image)
    }
    
    private mutating func appendRedo(image: CGImage?) {
        guard let image = image else { return }
        
        if redoList.count >= sizeLimit {
            redoList.removeFirst()
        }
        
        redoList.append(image)
    }
    
    private mutating func resetUndo() {
        undoList.removeAll()
    }
    
    private mutating func resetRedo() {
        redoList.removeAll()
    }
    
    // MARK: - Public
    mutating func append(image: CGImage?) {
        appendUndo(image: image)
        resetRedo()
    }
    
    mutating func undo() {
        guard canUndo else {
            return
        }
        
        let last = undoList.removeLast()
        appendRedo(image: last)
    }
    
    mutating func redo() {
        guard canRedo else {
            return
        }
        
        let last = redoList.removeLast()
        appendUndo(image: last)
    }
    
    mutating func clear() {
        resetUndo()
        resetRedo()
    }
    
}

extension History: Serializable {
    
    var serializedDictionary: [String: Any] {
        return [
            "undoList": undoList.map { UIImage(cgImage: $0) },
            "redoList": redoList.map { UIImage(cgImage: $0) }
        ]
    }
    
    init?(serializedDictionary: [String: Any]) {
        guard let undoList = serializedDictionary["undoList"] as? [UIImage],
              let redoList = serializedDictionary["redoList"] as? [UIImage] else {
                return nil
        }
        
        self.undoList = undoList.compactMap { $0.cgImage }
        self.redoList = redoList.compactMap { $0.cgImage }
    }
    
}
