
import UIKit

class DoodleLayout: UICollectionViewFlowLayout {
    
    override func prepare() {
        super.prepare()
        
        minimumLineSpacing = 10
        minimumInteritemSpacing = 10
        
        guard let cv = collectionView else {
            return
        }
        
        let workingWidth = cv.bounds.width - cv.contentInset.left - cv.contentInset.right
        let cellWidth = (workingWidth - minimumInteritemSpacing) / 2
        
        itemSize = CGSize(width: cellWidth, height: cellWidth)
    }
    
}
