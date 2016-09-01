
import UIKit

struct DrawComponent {
    var path: CGPath
    var width: CGFloat
    var color: CGColor
}

class DrawableView: UIView {
    
    // MARK: - Private Variables -
    private var currentPoint: CGPoint?
    private var previousPoint: CGPoint?
    private var previousPreviousPoint: CGPoint?
    
    var doodleToEdit: Doodle? {
        didSet {
            if let doodle = doodleToEdit {
                history = doodle.history
                bufferImage = doodle.history.lastImage
                setNeedsDisplay()
            }
        }
    }
    var history = History()
    
    var doodle: Doodle {
        let stickerImage = bufferImage?.autoCroppedImage?.verticallyFlipped ?? UIImage()
        let stickerData = UIImagePNGRepresentation(stickerImage) ?? Data()
        
        return Doodle(
            createdDate: doodleToEdit?.createdDate ?? Date(),
            updatedDate: Date(),
            history: history,
            stickerImageData: stickerData,
            previewImage: imageByCapturing
        )
    }
    
    private var drawingComponents = [DrawComponent]()
    
    private lazy var bufferContext: CGContext = {
        let scale = self.window!.screen.scale
        var size = self.bounds.size
        
        size.width *= scale
        size.height *= scale
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let ctx = CGContext(
            data: nil,
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )
        
        ctx?.setLineCap(.round)
        ctx?.concatenate(CGAffineTransform(scaleX: scale, y: scale))
        
        return ctx!
    }()
    
    private var bufferImage: CGImage?
    
    // MARK: - Public Helpers -
    func clear() {
        history.clear()

        bufferImage = nil
        bufferContext.clear(bounds)
        drawingComponents.removeAll()
        history.append(image: bufferImage)
        
        setNeedsDisplay()
    }
    
    func undo() {
        guard history.canUndo else { return }
        history.undo()
        
        bufferImage = history.lastImage
        setNeedsDisplay()
    }
    
    func redo() {
        guard history.canRedo else { return }
        history.redo()
        
        bufferImage = history.lastImage
        setNeedsDisplay()
    }
    
    func setupAndDrawWithPoints(points: [CGPoint], withColor color: CGColor, withWidth width: CGFloat) {
        let mid1 = midPoint(points[1], point2: points[2])
        let mid2 = midPoint(points[0], point2: points[1])
        
        let subPath = CGMutablePath()
        subPath.move(to: CGPoint(x: mid1.x, y: mid1.y))
        subPath.addQuadCurve(to: CGPoint(x: mid2.x, y: mid2.y), control: CGPoint(x: points[1].x, y: points[1].y))
        
        let boxOffset = CGFloat(SettingsController.sharedController.currentStrokeWidth())
        let drawBounds = subPath.boundingBox.insetBy(dx: -boxOffset, dy: -boxOffset)
        
        drawingComponents.append(DrawComponent(path: subPath, width: width, color: color))
        
        setNeedsDisplay(drawBounds)
    }
    
    //MARK: - Private API -
    private func midPoint(_ point1: CGPoint, point2: CGPoint) -> CGPoint {
        return CGPoint(x: (point1.x + point2.x) * 0.5, y: (point1.y + point2.y) * 0.5)
    }
    
    private func renderComponentsToBuffer() {
        let ctx = bufferContext
        
        for comp in drawingComponents {
            ctx.setLineCap(.round)
            ctx.setStrokeColor(comp.color)
            ctx.setLineWidth(comp.width)
            
            ctx.addPath(comp.path)
            ctx.strokePath()
        }
        
        bufferImage = bufferContext.makeImage()
        history.append(image: bufferImage)
        drawingComponents.removeAll()
    }
    
    //MARK - UIView Lifecycle -
    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        
        UIColor.white.setFill()
        UIRectFill(rect)
        
        bufferImage = bufferImage ?? bufferContext.makeImage()
        
        if let img = bufferImage {
            ctx.draw(img, in: bounds)
        }
        
        for comp in drawingComponents {
            ctx.setLineCap(.round)
            ctx.setStrokeColor(comp.color)
            ctx.setLineWidth(comp.width)
            
            ctx.addPath(comp.path)
            ctx.strokePath()
        }
    }
    
    //MARK: - UITouch Event Handling -
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (event?.allTouches?.count ?? 0) > 1 { return }
        
        if let touch = touches.first {
            previousPoint = touch.previousLocation(in: self)
            previousPreviousPoint = touch.previousLocation(in: self)
            currentPoint = touch.location(in: self)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (event?.allTouches?.count ?? 0) > 1 { return }
        
        guard let firstTouch = touches.first else { return }
        
        let point = firstTouch.location(in: self)
        
        let dx = point.x - currentPoint!.x
        let dy = point.y - currentPoint!.y
        
        if (dx * dx + dy * dy) < CGFloat(SettingsController.sharedController.currentStrokeWidth()) {
            return
        }
        
        previousPreviousPoint = previousPoint
        previousPoint = firstTouch.previousLocation(in: self)
        currentPoint = firstTouch.location(in: self)
        
        let drawColor = SettingsController.sharedController.currentDrawColor().cgColor
        let drawWidth = CGFloat(SettingsController.sharedController.currentStrokeWidth())
        let points = [currentPoint!, previousPoint!, previousPreviousPoint!]
        
        setupAndDrawWithPoints(points: points, withColor: drawColor, withWidth: drawWidth)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (event?.allTouches?.count ?? 0) > 1 { return }
        
        let drawColor = SettingsController.sharedController.currentDrawColor().cgColor
        let drawWidth = CGFloat(SettingsController.sharedController.currentStrokeWidth())
        let points = [currentPoint!, previousPoint!, previousPreviousPoint!]
        
        setupAndDrawWithPoints(points: points, withColor: drawColor, withWidth: drawWidth)
        
        renderComponentsToBuffer()
    }
    
}
