
import UIKit

class DoodlesViewController: UIViewController {
    
    fileprivate var doodles = [Doodle]() {
        didSet {
            if doodles.count > 0 {
                navigationItem.leftBarButtonItem = editButtonItem
            }
            else {
                navigationItem.leftBarButtonItem = nil
            }
        }
    }
    
    fileprivate var collectionView: UICollectionView!
    fileprivate var transitionAnimator: DoodleAnimator?
    fileprivate var shouldAutoPresentDoodle = true
    
    fileprivate var sortedDoodles: [Doodle] {
        return doodles.sorted(by: { first, second in
            return first.updatedDate > second.updatedDate
        })
    }
    
    fileprivate lazy var wobble: CAKeyframeAnimation = {
        let wobble = CAKeyframeAnimation(keyPath: "transform.rotation")
        wobble.duration = 0.25
        wobble.repeatCount = Float.infinity
        wobble.values = [0.0, -M_PI_4/25, 0.0, M_PI_4/25, 0.0]
        wobble.keyTimes = [0.0, 0.25, 0.5, 0.75, 1.0]
        return wobble
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Doodles"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(DoodlesViewController.addButtonPressed)
        )
        
        view.backgroundColor = UIColor.backgroundColor
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: DoodleLayout())
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = view.backgroundColor
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        collectionView.register(
            UINib(nibName: String(describing: DoodleCell.self), bundle: Bundle.main),
            forCellWithReuseIdentifier: String(describing: DoodleCell.self)
        )
        
        view.addSubview(collectionView)                
        view.addConstraints(NSLayoutConstraint.constraints(forPinningViewToSuperview: collectionView))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DocumentsController.sharedController.clearCache()
        doodles = DocumentsController.sharedController.doodles()
        collectionView.reloadData()
        
        if shouldAutoPresentDoodle && doodles.count == 0 {
            startNewDoodle()
            shouldAutoPresentDoodle = false
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
    }
    
    // MARK: - Actions
    
    @objc private func addButtonPressed() {
        startNewDoodle()
    }
    
    // MARK: - Helpers
    
    fileprivate func startNewDoodle() {
        setEditing(false, animated: true)
        
        transitionAnimator = DoodleAnimator(duration: 0.5)
        transitionAnimator?.presenting = true
        
        let vc = CanvasViewController()
        vc.delegate = self
        vc.transitioningDelegate = self
        present(vc, animated: true, completion: nil)
    }
    
    fileprivate func refreshView() {
        let prevDoodles = doodles
        doodles = DocumentsController.sharedController.doodles()
        
        if doodles.count > prevDoodles.count {
            collectionView.insertItems(at: [IndexPath(item: 0, section: 0)])
        }
        else if doodles.count < prevDoodles.count {
            if let deletedDoodle = prevDoodles.filter({ doodles.contains($0) }).last, let itemToDelete = prevDoodles.index(of: deletedDoodle) {
                collectionView.deleteItems(at: [IndexPath(item: itemToDelete, section: 0)])
            }
        }
        
        collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
    }
    
}


extension DoodlesViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: - CollectionView Delegate & DataSource
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: DoodleCell.self), for: indexPath) as? DoodleCell else {
            fatalError("Expected to display cell of type 'DoodleCell'.")
        }
        
        let doodle = sortedDoodles[indexPath.item]
        
        cell.imageView.image = doodle.previewImage
        
        let animationKey = "animation"
        
        if isEditing {
            cell.layer.add(wobble, forKey: animationKey)
            cell.maskImageView.isHidden = false
        }
        else {
            cell.layer.removeAnimation(forKey: animationKey)
            cell.maskImageView.isHidden = true
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isEditing {
            let ac = UIAlertController(
                title: "Warning",
                message: "Are you sure you want to delete this doodle?",
                preferredStyle: .alert
            )
            ac.addAction(
                UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                    DocumentsController.sharedController.delete(doodle: self.sortedDoodles[indexPath.item]) { success in
                        if success {
                            self.refreshView()
                        }
                    }
                })
            )
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(ac, animated: true, completion: nil)
        }
        else {
            if let cell = collectionView.cellForItem(at: indexPath) as? DoodleCell {
                let frame = cell.convert(cell.imageView.frame, to: collectionView)
                transitionAnimator = DoodleAnimator(duration: 0.5, originatingFrame: frame)
                transitionAnimator?.presenting = true
                transitionAnimator?.imageView = cell.imageView
            }
            
            let vc = CanvasViewController()
            vc.delegate = self
            vc.transitioningDelegate = self
            vc.doodleToEdit = sortedDoodles[indexPath.item]
            present(vc, animated: true, completion: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sortedDoodles.count
    }
    
}

extension DoodlesViewController: CanvasViewControllerDelegate {
    
    func canvasViewControllerShouldDismiss() {
        dismiss(animated: true, completion: nil)
    }
    
    func canvasViewControllerDidSaveDoodle() {
        dismiss(animated: true, completion: nil)
        refreshView()
    }
    
}

extension DoodlesViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return transitionAnimator
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transitionAnimator?.presenting = false
        return transitionAnimator
    }
    
}
