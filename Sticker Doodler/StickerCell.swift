
import UIKit
import Messages

class StickerCell: UICollectionViewCell {
    
    let stickerView = MSStickerView(frame: .zero)
    var sticker: MSSticker! {
        didSet {
            stickerView.sticker = sticker
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if stickerView.superview == nil {
            addSubview(stickerView)
            
            stickerView.translatesAutoresizingMaskIntoConstraints = false
            
            stickerView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            stickerView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            stickerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
            stickerView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        }
    }
    
}
