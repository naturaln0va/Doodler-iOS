
import UIKit

class DoodlesViewController: UIViewController {
    
    private var doodles = [Doodle]() {
        didSet {
            if doodles.count > 0 {
                navigationItem.leftBarButtonItem = editButtonItem
            }
            else {
                navigationItem.leftBarButtonItem = nil
            }
        }
    }
    
    private var collectionView: UICollectionView!
    private var transitionAnimator: DoodleAnimator?
    private var shouldAutoPresentDoodle = true
    
    private var sortedDoodles: [Doodle] {
        return doodles.sorted(by: { first, second in
            return first.updatedDate > second.updatedDate
        })
    }
    
    private var selectedDoodles = [Doodle]()
    
    private lazy var wobble: CAKeyframeAnimation = {
        let wobble = CAKeyframeAnimation(keyPath: "transform.rotation")
        wobble.duration = 0.25
        wobble.repeatCount = Float.infinity
        let fracPi = Float.pi / 180
        wobble.values = [0.0, -fracPi, 0.0, fracPi, 0.0]
        wobble.keyTimes = [0.0, 0.25, 0.5, 0.75, 1.0]
        return wobble
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("DOODLES", comment: "Doodles")
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonPressed)
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
        
        doodles = DocumentsController.sharedController.doodles()
        collectionView.reloadData()
        
        if shouldAutoPresentDoodle && doodles.count == 0 {
            startNewDoodle()
            shouldAutoPresentDoodle = false
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        title = editing ? NSLocalizedString("SELECT", comment: "Select") : NSLocalizedString("DOODLES", comment: "Doodles")
        
        collectionView.allowsSelection = !editing
        collectionView.allowsMultipleSelection = editing
        
        if editing {
            navigationItem.rightBarButtonItems = [
                UIBarButtonItem(
                    barButtonSystemItem: .trash,
                    target: self,
                    action: #selector(deleteButtonPressed)
                ),
                UIBarButtonItem(
                    barButtonSystemItem: .action,
                    target: self, 
                    action: #selector(shareButtonPressed)
                )
            ]
        }
        else {
            navigationItem.rightBarButtonItems = nil
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .add,
                target: self,
                action: #selector(addButtonPressed)
            )
            selectedDoodles.removeAll()
        }
        
        collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
    }
    
    // MARK: - Actions
    
    @objc private func addButtonPressed() {
        startNewDoodle()
    }
    
    @objc private func deleteButtonPressed() {
        guard selectedDoodles.count > 0 else { return }
        
        let ac = UIAlertController(
            title: NSLocalizedString("WARNING", comment: "Warning"),
            message: NSLocalizedString("WARNINGPROMPT", comment: "Are you sure you want to delete these doodles?"),
            preferredStyle: .alert
        )
        ac.addAction(
            UIAlertAction(title: NSLocalizedString("DELETE", comment: "Delete"), style: .destructive, handler: { _ in
                DocumentsController.sharedController.delete(doodles: self.selectedDoodles) { success in
                    if success {
                        self.refreshView()
                        self.setEditing(false, animated: true)
                    }
                }
            })
        )
        ac.addAction(UIAlertAction(title: NSLocalizedString("CANCEL", comment: "Cancel"), style: .cancel, handler: nil))
        present(ac, animated: true, completion: nil)
    }
    
    @objc private func shareButtonPressed() {
        var items: [Any] = [
            NSLocalizedString("DOODLERSHARE", comment: "Made with Doodler"),
            URL(string: "https://itunes.apple.com/us/app/doodler-simple-drawing/id948139703?mt=8")!
        ]
        
        items.append(contentsOf: selectedDoodles.map { $0.previewImage })
        
        let ac = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        ac.excludedActivityTypes = [.assignToContact, .addToReadingList, .print]
        
        ac.setupPopoverInView(sourceView: view, barButtonItem: navigationItem.rightBarButtonItem)
        present(ac, animated: true, completion: nil)
    }
    
    // MARK: - Helpers
    
    private func startNewDoodle() {
        setEditing(false, animated: true)
        
        transitionAnimator = DoodleAnimator(duration: 0.5)
        transitionAnimator?.presenting = true
        
        let vc = CanvasViewController()
        vc.delegate = self
        vc.transitioningDelegate = self
        present(vc, animated: true, completion: nil)
    }
    
    private func refreshView() {
        let prevDoodles = doodles
        doodles = DocumentsController.sharedController.doodles()
        
        if doodles.count > prevDoodles.count {
            if collectionView.numberOfSections == 0 {
                collectionView.insertSections(IndexSet([0]))
            }
            else {
                collectionView.insertItems(at: [IndexPath(item: 0, section: 0)])
            }
        }
        else if doodles.count == 0 {
            collectionView.deleteSections(IndexSet([0]))
        }
        else if doodles.count < prevDoodles.count {
            if let deletedDoodle = prevDoodles.filter({ doodles.contains($0) }).last, let itemToDelete = prevDoodles.firstIndex(of: deletedDoodle) {
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
        }
        else {
            cell.layer.removeAnimation(forKey: animationKey)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isEditing {
            if let index = selectedDoodles.firstIndex(of: sortedDoodles[indexPath.item]) {
                selectedDoodles.remove(at: index)
            }
            else {
                selectedDoodles.append(sortedDoodles[indexPath.item])
            }
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
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sortedDoodles.count > 0 ? 1 : 0
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
