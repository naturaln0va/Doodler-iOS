
import UIKit

struct History {
    
    private let sizeLimit = 25
    private var undoList = [CGImage]()
    private var redoList = [CGImage]()
    
    var lastImage: CGImage? {
        return undoList.last
    }
    
    var canUndo: Bool {
        return undoList.count > 0
    }
    
    var canRedo: Bool {
        return redoList.count > 0
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
        if let last = undoList.last {
            appendRedo(image: last)
            undoList.removeLast()
        }
    }
    
    mutating func redo() {
        if let last = redoList.last {
            appendUndo(image: last)
            redoList.removeLast()
        }
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
