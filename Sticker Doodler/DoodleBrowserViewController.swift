
import UIKit
import Messages

protocol DoodleBrowserViewControllerDelegate: class {
    func doodleBrowserViewControllerDidSelectAdd()
}

class DoodleBrowserViewController: UICollectionViewController {
    
    private var stickers = [MSSticker]()
    weak var delegate: DoodleBrowserViewControllerDelegate?
    
    init() {
        super.init(collectionViewLayout: StickerLayout())
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(collectionViewLayout: StickerLayout())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.register(CreateDoodleCell.self, forCellWithReuseIdentifier: String(describing: CreateDoodleCell.self))
        collectionView?.register(StickerCell.self, forCellWithReuseIdentifier: String(describing: StickerCell.self))
        collectionView?.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        collectionView?.backgroundColor = UIColor.white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadStickers()
    }
    
    // MARK: - Helpers
    
    private func loadStickers() {
        stickers.removeAll()
        for url in DocumentsController.sharedController.stickerURLs() where url.pathExtension.lowercased() == "png" {
            do {
                let sticker = try MSSticker(contentsOfFileURL: url, localizedDescription: NSUUID().uuidString)
                stickers.append(sticker)
            }
            catch let error {
                print("Error creating sticker with url: \(url).\nError: \(error)")
            }
        }
        stickers = stickers.sorted(by: { rhs, lhs -> Bool in
            guard let rhsCreatedDate = rhs.imageFileURL.createdDate, let lhsCreatedDate = lhs.imageFileURL.createdDate else {
                return false
            }
            print("Right side date: \(rhsCreatedDate). Left side date: \(lhsCreatedDate).")
            return rhsCreatedDate > lhsCreatedDate
        })
        collectionView?.reloadData()
    }
    
    // MARK: UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stickers.count + 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            return collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: CreateDoodleCell.self), for: indexPath)
        }
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: StickerCell.self), for: indexPath) as? StickerCell else {
            fatalError("Expected to display a cell of type 'StickerCell'.")
        }
        
        cell.sticker = stickers[indexPath.item - 1]
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? StickerCell {
            cell.sticker = stickers[indexPath.item - 1]
        }
    }
    
    // MARK: UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            delegate?.doodleBrowserViewControllerDidSelectAdd()
        }
        return
    }
    
}
