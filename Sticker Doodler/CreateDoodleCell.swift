
import UIKit

class CreateDoodleCell: UICollectionViewCell {
    
    let imageView = UIImageView(frame: .zero)
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if imageView.superview == nil {
            addSubview(imageView)
            
            imageView.translatesAutoresizingMaskIntoConstraints = false
            
            imageView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            imageView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            
            imageView.image = UIImage(named: "new-doodle")
            imageView.contentMode = .center
        }
    }
    
}
