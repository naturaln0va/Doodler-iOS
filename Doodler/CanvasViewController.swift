
import UIKit

protocol CanvasViewControllerDelegate: class {
    func canvasViewControllerShouldDismiss()
    func canvasViewControllerDidSaveDoodle()
}

class CanvasViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var doodleToEdit: Doodle?
    var shouldInsetLayoutForMessages = false
    
    weak var delegate: CanvasViewControllerDelegate?
    
    fileprivate var lastCanvasZoomScale = 0
    fileprivate var toolBarBottomConstraint: NSLayoutConstraint!
    
    var canvas: DrawableView!
    
    lazy var strokeSlider: UISlider = {
        let view = UISlider()
        
        view.minimumValue = 1
        view.maximumValue = 100
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setThumbImage(UIImage(named: "knob"), for: UIControlState.normal)
        view.addTarget(self, action: #selector(sliderUpdated(_:)), for: .valueChanged)
        view.setMinimumTrackImage(UIImage(named: "slider"), for: UIControlState.normal)
        view.setMaximumTrackImage(UIImage(named: "slider"), for: UIControlState.normal)
        view.setValue(SettingsController.sharedController.strokeWidth, animated: false)
        
        return view
    }()
    
    fileprivate lazy var strokeSizeView: StrokeSizeView = {
        let view = StrokeSizeView()
        
        view.alpha = 0
        view.clipsToBounds = true
        view.layer.borderWidth = 4
        view.layer.cornerRadius = 20
        view.layer.borderColor = UIColor.white.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    fileprivate lazy var toolbar: UIToolbar = {
        let view = UIToolbar()

        view.isTranslucent = true
        view.tintColor = UIColor.white
        view.barTintColor = UIColor.black
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    fileprivate lazy var segmentedControl: UISegmentedControl = {
        let view = UISegmentedControl(items: ["Draw", "Erase"])
        
        view.frame.size.width = 175
        view.selectedSegmentIndex = 0
        view.addTarget(self, action: #selector(segmentWasChanged(_:)), for: .valueChanged)
        
        return view
    }()
    
    fileprivate lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        
        view.delegate = self
        view.minimumZoomScale = 0.25
        view.maximumZoomScale = 12.5
        view.panGestureRecognizer.minimumNumberOfTouches = 2
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    fileprivate let colorButton = ColorPreviewButton(
        frame: CGRect(origin: .zero, size: CGSize(width: 27, height: 27))
    )
    
    fileprivate lazy var backButton = UIBarButtonItem(
        image: UIImage(named: "back-arrow-icon"),
        style: .plain,
        target: self,
        action: #selector(backButtonPressed)
    )
    fileprivate var actionButton = UIBarButtonItem(
        image: UIImage(named: "toolbox-icon"),
        style: .plain,
        target: self,
        action: #selector(actionButtonPressed)
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
        SettingsController.sharedController.disableEraser()
        
        let gridView = GridView()
        gridView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(gridView)
        view.addConstraints(
            NSLayoutConstraint.constraints(forPinningViewToSuperview: gridView)
        )
        
        view.addSubview(scrollView)
        view.addConstraints(NSLayoutConstraint.constraints(forPinningViewToSuperview: scrollView))
        
        view.addSubview(toolbar)
        view.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormats: [
                    "H:|[bar]|",
                    ],
                views: ["bar": toolbar]
            )
        )
        toolBarBottomConstraint = NSLayoutConstraint(
            item: view,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: toolbar,
            attribute: .bottom,
            multiplier: 1,
            constant: shouldInsetLayoutForMessages ? 44 : 0
        )
        view.addConstraint(toolBarBottomConstraint)
        
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
        view.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormats: [
                    "H:|-12-[slider]-12-|",
                    "V:|-topSpace-[slider]"
                ],
                metrics: ["topSpace": shouldInsetLayoutForMessages ? 86 : 0],
                views: ["slider": strokeSlider]
            )
        )
        
        toolbar.items = [
            backButton,
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(customView: segmentedControl),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            actionButton,
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(customView: colorButton),
        ]
        
        colorButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(colorButtonPressed)))
        colorButton.color = SettingsController.sharedController.strokeColor
        
        hideToolbar()
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
        
        if view.frame.width > 0 && canvas == nil {
            canvas = DrawableView()
            canvas.backgroundColor = .white
            
            canvas.frame = view.frame
            canvas.doodleToEdit = doodleToEdit
            canvas.isUserInteractionEnabled = true
            canvas.layer.magnificationFilter = kCAFilterLinear
            
            scrollView.addSubview(canvas)
            scrollView.contentSize = canvas.bounds.size
            
            centerScrollViewContents()
        }
    }
    
    //MARK: - Actions -
    @objc private func actionButtonPressed() {
        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        ac.addAction(
            UIAlertAction(title: "Share", style: .default) { action in
                let activityViewcontroller = UIActivityViewController(activityItems: ["Made with Doodler", URL(string: "http://apple.co/1IUYyFk")!, self.canvas.imageByCapturing], applicationActivities: nil)
                activityViewcontroller.excludedActivityTypes = [
                    .assignToContact, .addToReadingList, .print
                ]
                
                self.present(activityViewcontroller, animated: true, completion: {})
            }
        )
        if canvas.history.canReset {
            ac.addAction(
                UIAlertAction(title: "Clear Screen", style: .destructive) { action in
                    self.clearScreen()
                }
            )
        }
        if canvas.history.canUndo {
            ac.addAction(
                UIAlertAction(title: "Undo", style: .default) { action in
                    self.canvas.undo()
                }
            )
        }
        if canvas.history.canRedo {
            ac.addAction(
                UIAlertAction(title: "Redo", style: .default) { action in
                    self.canvas.redo()
                }
            )
        }
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(ac, animated: true, completion: nil)
    }
    
    @objc private func colorButtonPressed() {
        let picker = ColorPickerViewController()
        picker.delegate = self
        picker.preferredContentSize = CGSize(width: 300, height: 420)
        picker.setupPopoverInView(sourceView: self.view, barButtonItem: self.toolbar.items?.last)
        self.present(picker, animated: true, completion: nil)
    }
    
    @objc private func backButtonPressed() {
        guard canvas.history.canReset else {
            delegate?.canvasViewControllerShouldDismiss()
            return
        }
        
        DocumentsController.sharedController.save(doodle: canvas.doodle) { success in
            if success {
                self.delegate?.canvasViewControllerDidSaveDoodle()
            }
            else {
                let alert = UIAlertController(title: nil, message: "Error saving doodle 😱", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    private func clearScreen() {
        let alert = UIAlertController(title: "Clear Screen", message: "Would you like to clear the screen?", preferredStyle: .alert)
        
        alert.addAction(
            UIAlertAction(title: "Clear", style: .destructive) { action in
                self.canvas.clear()
            }
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    func segmentWasChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            SettingsController.sharedController.disableEraser()
        }
        else if sender.selectedSegmentIndex == 1 {
            SettingsController.sharedController.enableEraser()
        }
    }
    
    func sliderUpdated(_ sender: UISlider) {
        SettingsController.sharedController.setStrokeWidth(sender.value)
        strokeSizeView.strokeSize = CGFloat(sender.value)
    }
    
    //MARK: - Helpers -
    
    func showToolbar() {
        toolBarBottomConstraint.constant = shouldInsetLayoutForMessages ? 44 : 0
        
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.05, initialSpringVelocity: 0.125, options: [], animations: {
            self.view.layoutIfNeeded()
        },
        completion: nil)
    }
    
    func hideToolbar() {
        toolBarBottomConstraint.constant = -toolbar.bounds.height
        
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
        } else {
            contentsFrame.origin.x = 0.0
        }
        
        if contentsFrame.size.height < boundsSize.height {
            contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0
        } else {
            contentsFrame.origin.y = 0.0
        }
        
        canvas.frame = contentsFrame
    }
    
    //MARK: - Motion Event Delegate -
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            clearScreen()
        }
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
        
        if scale > 750 {
            canvas.layer.magnificationFilter = kCAFilterNearest
        }
        else {
            canvas.layer.magnificationFilter = kCAFilterLinear
        }
        
        lastCanvasZoomScale = scale
        
        centerScrollViewContents()
    }
    
}

extension CanvasViewController: ColorPickerViewControllerDelegate {
    
    //MARK: - ColorPickerViewControllerDelegate Methods -
    func colorPickerViewControllerDidPickColor(_ color: UIColor) {
        colorButton.color = color
        SettingsController.sharedController.setStrokeColor(color)
    }
    
}
