
import UIKit

class DoodlesViewController: UIViewController {
    
    internal var doodles = [Doodle]()
    internal var collectionView: UICollectionView!
    
    internal lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Doodles"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .edit,
            target: self,
            action: #selector(DoodlesViewController.editButtonPressed)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(DoodlesViewController.addButtonPressed)
        )
        
        view.backgroundColor = UIColor.backgroundColor
        
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = view.backgroundColor
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
        collectionView.register(
            UINib(nibName: String(describing: DoodleCell.self), bundle: Bundle.main),
            forCellWithReuseIdentifier: String(describing: DoodleCell.self)
        )
        
        view.addSubview(collectionView)
        
        view.addConstraint(
            NSLayoutConstraint(
                item: collectionView,
                attribute: .top,
                relatedBy: .equal,
                toItem: view,
                attribute: .top,
                multiplier: 1,
                constant: 0
            )
        )
        view.addConstraint(
            NSLayoutConstraint(
                item: collectionView,
                attribute: .bottom,
                relatedBy: .equal,
                toItem: view,
                attribute: .bottom,
                multiplier: 1,
                constant: 0
            )
        )
        view.addConstraint(
            NSLayoutConstraint(
                item: collectionView,
                attribute: .trailing,
                relatedBy: .equal,
                toItem: view,
                attribute: .trailing,
                multiplier: 1,
                constant: 0
            )
        )
        view.addConstraint(
            NSLayoutConstraint(
                item: collectionView,
                attribute: .leading,
                relatedBy: .equal,
                toItem: view,
                attribute: .leading,
                multiplier: 1,
                constant: 0
            )
        )
        
        doodles = DocumentsController.sharedController.doodles()
    }
    
    // MARK: - Actions
    @objc private func editButtonPressed() {
        
    }
    
    @objc private func addButtonPressed() {
        let vc = CanvasViewController()
        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }
    
}


extension DoodlesViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // MARK: - CollectionView Delegate & DataSource
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: DoodleCell.self), for: indexPath) as? DoodleCell else {
            fatalError("Expected to display cell of type 'DoodleCell'.")
        }
        
        let doodle = doodles[indexPath.item]
        
        cell.imageView.image = doodle.image
        cell.dateLabel.text = dateFormatter.string(from: doodle.date)
        
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return doodles.count > 0 ? 1 : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return doodles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = ((collectionView.bounds.width - collectionView.contentInset.left - collectionView.contentInset.right) / 3) - 30
        
        return CGSize(width: width, height: (width * 4) / 3)
    }
    
}

extension DoodlesViewController: CanvasViewControllerDelegate {
    
    func canvasViewControllerDidDismiss() {
        dismiss(animated: true, completion: nil)
        doodles = DocumentsController.sharedController.doodles()
        
        collectionView?.reloadData()
    }
    
}
