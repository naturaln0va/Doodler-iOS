
import UIKit

class DoodlesViewController: UIViewController {
    
    private var doodles = [Doodle]() {
        didSet {
            editButtonItem.isEnabled = !doodles.isEmpty
        }
    }
    
    private var collectionView: UICollectionView!
    private var transitionAnimator: DoodleAnimator?
    private var shouldAutoPresentDoodle = true
    private var presentationManager: NavigationPresentationManager?
    
    private var sortedDoodles: [Doodle] {
        return doodles.sorted(by: { first, second in
            return first.updatedDate > second.updatedDate
        })
    }
    
    private var selectedDoodles = [Doodle]() {
        didSet {
            guard isEditing else {
                return
            }
            
            let shouldEnableBarButton = !selectedDoodles.isEmpty

            trashButtonItem.isEnabled = shouldEnableBarButton
            actionButtonItem.isEnabled = shouldEnableBarButton
        }
    }
    
    private lazy var wobble: CAKeyframeAnimation = {
        let wobble = CAKeyframeAnimation(keyPath: "transform.rotation")
        wobble.duration = 0.25
        wobble.repeatCount = Float.infinity
        let fracPi = Float.pi / 180
        wobble.values = [0.0, -fracPi, 0.0, fracPi, 0.0]
        wobble.keyTimes = [0.0, 0.25, 0.5, 0.75, 1.0]
        return wobble
    }()
    
    private lazy var addButtonItem = {
        return UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonPressed)
        )
    }()
    
    private lazy var trashButtonItem = {
        return UIBarButtonItem(
            barButtonSystemItem: .trash,
            target: self,
            action: #selector(deleteButtonPressed)
        )
    }()
    
    private lazy var actionButtonItem = {
        return UIBarButtonItem(
            barButtonSystemItem: .action,
            target: self,
            action: #selector(shareButtonPressed)
        )
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("DOODLES", comment: "Doodles")
        navigationController?.setToolbarHidden(false, animated: false)
        
//        navigationItem.leftBarButtonItem = UIBarButtonItem(
//            image: UIImage(systemName: "gear"),
//            style: .plain,
//            target: self,
//            action: #selector(settingsButtonPressed)
//        )
        
        doodles = DocumentsController.sharedController.doodles
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
        
        refreshToolbarItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                
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
                
        refreshToolbarItems()
        selectedDoodles.removeAll()
        
        collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
    }
    
    // MARK: - Actions
    
    @objc private func addButtonPressed() {
        let vc = NewDoodleViewController()
        vc.delegate = self
                        
        presentationManager = NavigationPresentationManager(viewController: vc)
        presentationManager?.present(from: self)
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
            URL(string: "https://apps.apple.com/us/app/doodler-sticker-drawing/id948139703")!
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
    
    @objc private func settingsButtonPressed() {
        // Use in app settings instead
    }
    
    // MARK: - Helpers
    
    private func refreshToolbarItems() {
        var toolbarItems = [UIBarButtonItem]()
        
        let flexibleSpaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let fixedSpaceItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixedSpaceItem.width = 18

        if isEditing {
            trashButtonItem.isEnabled = false
            actionButtonItem.isEnabled = false
            
            toolbarItems = [editButtonItem, flexibleSpaceItem, trashButtonItem, fixedSpaceItem, actionButtonItem]
        }
        else {
            toolbarItems = [editButtonItem, flexibleSpaceItem, addButtonItem]
        }
        
        self.toolbarItems = toolbarItems
    }
    
    private func startNewDoodle() {
        setEditing(false, animated: true)
        
        transitionAnimator = DoodleAnimator(duration: 0.35)
        transitionAnimator?.presenting = true
        
        let vc = CanvasViewController(size: view.bounds.size)
        vc.delegate = self
        vc.transitioningDelegate = self
        vc.modalPresentationStyle = .custom
        present(vc, animated: true, completion: nil)
    }
    
    private func refreshView() {
        let prevDoodles = doodles
        doodles = DocumentsController.sharedController.doodles
        
        if doodles.count > prevDoodles.count {
            if collectionView.numberOfSections == 0 {
                collectionView.insertSections(IndexSet([0]))
            }
            else {
                collectionView.insertItems(at: [IndexPath(item: 0, section: 0)])
            }
        }
        else if doodles.count == 0 && collectionView.numberOfSections > 0 {
            collectionView.deleteSections(IndexSet([0]))
        }
        else if doodles.count < prevDoodles.count {
            if let deletedDoodle = prevDoodles.filter({ doodles.contains($0) }).last, let itemToDelete = prevDoodles.firstIndex(of: deletedDoodle) {
                collectionView.deleteItems(at: [IndexPath(item: itemToDelete, section: 0)])
            }
        }
        
        if !doodles.isEmpty {
            collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
        }
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
            selectedDoodles.append(sortedDoodles[indexPath.item])
        }
        else {
            if let cell = collectionView.cellForItem(at: indexPath) as? DoodleCell {
                let frame = cell.convert(cell.imageView.frame, to: navigationController?.view)
                transitionAnimator = DoodleAnimator(duration: 0.35, originatingFrame: frame)
                transitionAnimator?.imageView = cell.imageView
            }
            
            let doodle = sortedDoodles[indexPath.item]
            
            let vc = CanvasViewController(size: doodle.size)
            transitionAnimator?.presenting = true

            vc.delegate = self
            vc.doodleToEdit = doodle
            vc.transitioningDelegate = self
            vc.modalPresentationStyle = .custom
            present(vc, animated: true, completion: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard isEditing else {
            return
        }
        
        if let index = selectedDoodles.firstIndex(of: sortedDoodles[indexPath.item]) {
            selectedDoodles.remove(at: index)
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
    
    private func deselectAndDismiss() {
        if let indexPath = collectionView.indexPathsForSelectedItems?.first {
            collectionView.deselectItem(at: indexPath, animated: true)
        }

        dismiss(animated: true, completion: nil)
    }

    func canvasViewControllerShouldDismiss(_ vc: CanvasViewController, didSave: Bool) {
        deselectAndDismiss()
        
        guard didSave else {
            return
        }
        
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

extension DoodlesViewController: NewDoodleViewControllerDelegate {
    
    func newDoodleViewControllerDidComplete(with size: CGSize) {
        transitionAnimator = DoodleAnimator(duration: 0.35)
        transitionAnimator?.presenting = true

        let vc = CanvasViewController(size: size)
        
        vc.delegate = self
        vc.transitioningDelegate = self
        vc.modalPresentationStyle = .custom

        present(vc, animated: true, completion: nil)
    }
    
}

extension DoodlesViewController: UIDocumentPickerDelegate {
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        for url in urls {
            print("URL: \(url.absoluteString)")
        }
    }
    
}
