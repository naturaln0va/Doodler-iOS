
import UIKit

protocol CanvasViewControllerDelegate: class {
    func canvasViewControllerShouldDismiss()
    func canvasViewControllerDidSaveDoodle()
}

class CanvasViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var doodleToEdit: Doodle?
    var isPresentingWithinMessages = false
    
    weak var delegate: CanvasViewControllerDelegate?
    
    private var lastCanvasZoomScale = 0
    private var pendingPickedColor: UIColor?
    private var toolBarBottomConstraint: NSLayoutConstraint!
    
    var canvas: DrawableView!
    
    private lazy var gridView: GridView = {
        let view = GridView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    lazy var strokeSlider: UISlider = {
        let view = UISlider()
        
        view.minimumValue = 1
        view.maximumValue = 100
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setThumbImage(UIImage(named: "knob"), for: .normal)
        view.addTarget(self, action: #selector(sliderUpdated(_:)), for: .valueChanged)
        view.setMinimumTrackImage(UIImage(named: "slider"), for: .normal)
        view.setMaximumTrackImage(UIImage(named: "slider"), for: .normal)
        view.setValue(SettingsController.shared.strokeWidth, animated: false)
        
        return view
    }()
    
    private lazy var strokeSizeView: StrokeSizeView = {
        let view = StrokeSizeView()
        
        view.alpha = 0
        view.clipsToBounds = true
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var blurStatusView: UIVisualEffectView = {
        let style: UIBlurEffect.Style
        
        if #available(iOS 13.0, *) {
            style = .systemChromeMaterialDark
        }
        else {
            style = .dark
        }

        let view = UIVisualEffectView(effect: UIBlurEffect(style: style))
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()
    
    private(set) lazy var toolbar: UIToolbar = {
        let view = UIToolbar()

        view.isTranslucent = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.barTintColor = self.isPresentingWithinMessages ? UIColor(white: 0.98899, alpha: 1.0) : UIColor.black
        view.tintColor = self.isPresentingWithinMessages ? UIColor(red: 0.52,  green: 0.56,  blue: 0.6, alpha: 1.0) : UIColor.white
        
        return view
    }()
    
    private lazy var segmentedControl: UISegmentedControl = {
        let view = UISegmentedControl(items:
            [
                NSLocalizedString("DRAW", comment: "Draw"),
                NSLocalizedString("ERASE", comment: "Erase")
            ]
        )
        
        view.frame.size.width = 175
        view.selectedSegmentIndex = 0
        if !self.isPresentingWithinMessages {
            view.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
            view.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
        }
        view.addTarget(self, action: #selector(segmentWasChanged(_:)), for: .valueChanged)
        
        return view
    }()
    
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        
        view.delegate = self
        view.minimumZoomScale = 0.25
        view.maximumZoomScale = 12.5
        view.panGestureRecognizer.minimumNumberOfTouches = 2
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private let colorButton = ColorPreviewButton(
        frame: CGRect(origin: .zero, size: CGSize(width: 27, height: 27))
    )
    
    private var segmentBarButton: UIBarButtonItem!
    private var colorPickerBarButton: UIBarButtonItem!
    private lazy var backButton = UIBarButtonItem(
        image: UIImage(named: "back-arrow-icon"),
        style: .plain,
        target: self,
        action: #selector(backButtonPressed)
    )
    private lazy var actionButton = UIBarButtonItem(
        image: UIImage(named: "toolbox-icon"),
        style: .plain,
        target: self,
        action: #selector(actionButtonPressed)
    )
    private lazy var undoButton = UIBarButtonItem(
        title: NSLocalizedString("UNDO", comment: "Undo"),
        style: .plain,
        target: self,
        action: #selector(undoButtonPressed)
    )
    private lazy var redoButton = UIBarButtonItem(
        title: NSLocalizedString("REDO", comment: "Redo"),
        style: .plain,
        target: self,
        action: #selector(redoButtonPressed)
    )
    private lazy var shareButton = UIBarButtonItem(
        image: UIImage(named: "share-button"),
        style: .plain,
        target: self,
        action: #selector(shareButtonPressed)
    )
    
    //MARK: - ViewController Delegate -
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.backgroundColor
        SettingsController.shared.disableEraser()
        
        view.addSubview(gridView)
        view.addConstraints(NSLayoutConstraint.constraints(forPinningViewToSuperview: gridView))
        
        view.addSubview(scrollView)
        view.addConstraints(NSLayoutConstraint.constraints(forPinningViewToSuperview: scrollView))
        
        view.addSubview(toolbar)
        NSLayoutConstraint.activate([
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        toolBarBottomConstraint = toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        toolBarBottomConstraint.isActive = true
        
        view.addSubview(blurStatusView)
        NSLayoutConstraint.activate([
            blurStatusView.topAnchor.constraint(equalTo: view.topAnchor),
            blurStatusView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            blurStatusView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            blurStatusView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
        view.addSubview(strokeSizeView)
        view.addConstraints(
            NSLayoutConstraint.constraints(
                forConstrainingView: strokeSizeView,
                toSize: CGSize(width: 125, height: 125)
            )
        )
        view.addConstraints(
            NSLayoutConstraint.constraints(forCenteringView: strokeSizeView)
        )
        
        view.addSubview(strokeSlider)
        NSLayoutConstraint.activate([
            strokeSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            strokeSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            strokeSlider.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8)
        ])
        
        segmentBarButton = UIBarButtonItem(customView: segmentedControl)
        colorPickerBarButton = UIBarButtonItem(customView: colorButton)
        
        colorButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(colorButtonPressed)))
        colorButton.color = SettingsController.shared.strokeColor
                
        hideToolbar()
        refreshToolbarItems()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        showToolbar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        hideToolbar()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if view.bounds.width > 0 && canvas == nil {
            let frameSize = view.frame.size
            
            canvas = DrawableView(frame: CGRect(origin: .zero, size: frameSize))
            canvas.backgroundColor = .white
            
            canvas.doodleToEdit = doodleToEdit
            canvas.isUserInteractionEnabled = true
            canvas.layer.magnificationFilter = .linear
            canvas.addGestureRecognizer(
                UILongPressGestureRecognizer(target: self, action: #selector(handle(longPress:)))
            )
            
            scrollView.addSubview(canvas)
            scrollView.contentSize = canvas.bounds.size
            
            let canvasTransformValue = view.frame.width / canvas.frame.width
            canvas.transform = CGAffineTransform(scaleX: canvasTransformValue, y: canvasTransformValue)
            
            centerScrollViewContents()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        gridView.setNeedsDisplay()
        
        coordinator.animate(alongsideTransition: nil) { context in
            self.centerScrollViewContents()
        }
    }
    
    //MARK: - Actions -
    @objc private func handle(longPress gesture: UILongPressGestureRecognizer) {
        guard let gestureView = gesture.view else { return }
        guard gesture.state == .began else { return }
        
        let position = gesture.location(in: gestureView)
        pendingPickedColor = canvas.imageByCapturing.color(at: position)
        
        guard pendingPickedColor != nil else { return }
        
        UIMenuController.shared.setTargetRect(CGRect(origin: position, size: .zero), in: gestureView)
        UIMenuController.shared.setMenuVisible(true, animated: true)
        UIMenuController.shared.menuItems = [UIMenuItem(title: NSLocalizedString("PICKCOLOR", comment: "Pick Color"), action: #selector(selectColor))]
        
        gestureView.becomeFirstResponder()
    }
    
    @objc private func undoButtonPressed() {
        canvas.undo()
    }
    
    @objc private func redoButtonPressed() {
        canvas.redo()
    }
    
    @objc private func shareButtonPressed() {
        let ac = UIActivityViewController(activityItems: [NSLocalizedString("DOODLERSHARE", comment: "Made with Doodler"), URL(string: "https://itunes.apple.com/us/app/doodler-simple-drawing/id948139703?mt=8")!, self.canvas.imageByCapturing], applicationActivities: nil)
        ac.excludedActivityTypes = [
            .assignToContact, .addToReadingList, .print
        ]
        
        ac.setupPopoverInView(sourceView: view, barButtonItem: shareButton)
        present(ac, animated: true, completion: nil)
    }
    
    @objc private func actionButtonPressed() {
        let vc = ActionMenuViewController(isPresentingWithinMessages: isPresentingWithinMessages)
        
        vc.delegate = self
        vc.drawableView = canvas
        vc.preferredContentSize = vc.contentSize
        vc.setupPopoverInView(sourceView: view, barButtonItem: actionButton)
        
        present(vc, animated: true, completion: nil)
    }
    
    @objc private func colorButtonPressed() {
        let picker = ColorPickerViewController()
        
        picker.delegate = self
        picker.preferredContentSize = CGSize(width: 300, height: 366)
        picker.setupPopoverInView(sourceView: view, barButtonItem: toolbar.items?.last)
        
        present(picker, animated: true, completion: nil)
    }
    
    @objc private func backButtonPressed() {
        guard canvas.history.canReset && canvas.isDirty else {
            delegate?.canvasViewControllerShouldDismiss()
            return
        }
        
        let activityIndicator = UIActivityIndicatorView(style: .white)
        activityIndicator.tintColor = isPresentingWithinMessages ? UIColor(red: 0.52,  green: 0.56,  blue: 0.6, alpha: 1.0) : .white
        activityIndicator.startAnimating()
        
        let previousItems = toolbar.items
        
        toolbar.items?.removeFirst()
        toolbar.items?.insert(UIBarButtonItem(customView: activityIndicator), at: 0)
        
        let preview = canvas.imageByCapturing
        
        DispatchQueue(label: "io.ackermann.imageCreate").async {
            let stickerImage = self.canvas.bufferImage?.autoCroppedImage?.verticallyFlipped ?? UIImage()
            let stickerData = stickerImage.pngData() ?? Data()
            
            let doodle =  Doodle(
                createdDate: self.doodleToEdit?.createdDate ?? Date(),
                updatedDate: Date(),
                history: self.canvas.history,
                stickerImageData: stickerData,
                previewImage: preview
            )
            
            DocumentsController.sharedController.save(doodle: doodle) { success in
                if success {
                    self.delegate?.canvasViewControllerDidSaveDoodle()
                }
                else {
                    self.toolbar.items = previousItems
                    
                    let alert = UIAlertController(title: nil, message: NSLocalizedString("ERRORSAVING", comment: "Error saving doodle."), preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("CANCEL", comment: "Cancel"), style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    @objc private func selectColor() {
        if let color = pendingPickedColor {
            update(to: color)
            pendingPickedColor = nil
        }
    }
    
    @objc private func clearScreen() {
        let alert = UIAlertController(title: NSLocalizedString("CLEAR", comment: "Clear"), message: NSLocalizedString("CLEARPROMPT", comment: "Would you like to clear the screen?"), preferredStyle: .alert)
        
        alert.addAction(
            UIAlertAction(title: NSLocalizedString("CLEAR", comment: "Clear"), style: .destructive) { action in
                self.canvas.clear()
            }
        )
        alert.addAction(UIAlertAction(title: NSLocalizedString("CANCEL", comment: "Cancel"), style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc private func segmentWasChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            SettingsController.shared.disableEraser()
        }
        else if sender.selectedSegmentIndex == 1 {
            SettingsController.shared.enableEraser()
        }
    }
    
    @objc private func sliderUpdated(_ sender: UISlider) {
        SettingsController.shared.strokeWidth = sender.value
        strokeSizeView.strokeSize = CGFloat(sender.value)
    }
    
    // MARK: - Helpers -
    
    func refreshToolbarItems() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            toolbar.items = [
                backButton,
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                segmentBarButton,
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                undoButton,
                redoButton,
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                shareButton,
                colorPickerBarButton
            ]
        }
        else {
            toolbar.items = [
                backButton,
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                segmentBarButton,
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                actionButton,
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                colorPickerBarButton
            ]
        }
    }
    
    func update(to color: UIColor) {
        segmentedControl.selectedSegmentIndex = 0
        
        SettingsController.shared.disableEraser()
        SettingsController.shared.setStrokeColor(color)
        colorButton.color = color
    }
    
    func showToolbar() {
        toolBarBottomConstraint.constant = 0
        
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.05, initialSpringVelocity: 0.125, options: [], animations: {
            self.view.layoutIfNeeded()
        },
        completion: nil)
    }
    
    func hideToolbar() {
        toolBarBottomConstraint.constant = toolbar.bounds.height + view.safeAreaInsets.bottom
        
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.05, initialSpringVelocity: 0.125, options: [], animations: {
            self.view.layoutIfNeeded()
        },
        completion: nil)
    }
    
    func centerScrollViewContents() {
        let boundsSize = scrollView.bounds.size
        var contentsFrame = canvas.frame
        
        if contentsFrame.size.width < boundsSize.width {
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0
        }
        else {
            contentsFrame.origin.x = 0.0
        }
        
        if contentsFrame.size.height < boundsSize.height {
            contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0
        }
        else {
            contentsFrame.origin.y = 0.0
        }
        
        let minWidth = min(canvas.frame.width, canvas.frame.height)
        let maxHeight = max(canvas.frame.width, canvas.frame.height)

        canvas.frame = CGRect(origin: contentsFrame.origin, size: CGSize(width: minWidth, height: maxHeight))
    }
    
    //MARK: - Motion Event Delegate -
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        guard motion == .motionShake else {
            return
        }
        
        clearScreen()
    }
    
}

extension CanvasViewController: UIScrollViewDelegate {
    
    //MARK: - UIScrollViewDelegate -
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return canvas
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let scale = Int(scrollView.zoomScale * 100)
        
        if lastCanvasZoomScale < scale && (scrollView.pinchGestureRecognizer?.velocity ?? 0) > CGFloat(2) {
            hideToolbar()
        }
        else if lastCanvasZoomScale > scale && (scrollView.pinchGestureRecognizer?.velocity ?? 0) < CGFloat(-1) {
            showToolbar()
        }
        
        if scale > 675 {
            canvas.layer.magnificationFilter = .nearest
        }
        else {
            canvas.layer.magnificationFilter = .linear
        }
        
        lastCanvasZoomScale = scale
        
        centerScrollViewContents()
    }
    
}

extension CanvasViewController: ColorPickerViewControllerDelegate {
    
    //MARK: - ColorPickerViewControllerDelegate Methods -
    func colorPickerViewControllerDidPickColor(_ color: UIColor) {
        update(to: color)
    }
    
}

extension CanvasViewController: ActionMenuViewControllerDelegate {
    
    func actionMenuViewControllerDidSelectShare(vc: ActionMenuViewController) {
        vc.dismiss(animated: true, completion: nil)
        
        let ac = UIActivityViewController(activityItems: [NSLocalizedString("DOODLERSHARE", comment: "Made with Doodler"), URL(string: "https://itunes.apple.com/us/app/doodler-simple-drawing/id948139703?mt=8")!, self.canvas.imageByCapturing], applicationActivities: nil)
        ac.excludedActivityTypes = [
            .assignToContact, .addToReadingList, .print
        ]
        
        ac.setupPopoverInView(sourceView: view, barButtonItem: actionButton)
        present(ac, animated: true, completion: nil)
    }
    
    func actionMenuViewControllerDidSelectClear(vc: ActionMenuViewController) {
        vc.dismiss(animated: true, completion: nil)
        
        clearScreen()
    }
    
    func actionMenuViewControllerDidSelectUndo(vc: ActionMenuViewController) {
        canvas.undo()
        
        vc.drawableView = canvas
    }
    
    func actionMenuViewControllerDidSelectRedo(vc: ActionMenuViewController) {
        canvas.redo()
        
        vc.drawableView = canvas
    }
    
}
