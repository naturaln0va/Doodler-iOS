
import UIKit

class CanvasViewController: UIViewController, UIGestureRecognizerDelegate, UIScrollViewDelegate, ColorPickerViewControllerDelegate
{
    private let kDefaultCanvasSize = CGSize(
        width: UIScreen.main.bounds.size.width,
        height: UIScreen.main.bounds.size.height
    )
    
    var canvas: DrawableView!
    var scrollView: UIScrollView!
    var hasBeingInitiallySetup = false
    var lastCanvasZoomScale: Int?
    
    //Outlets
    @IBOutlet var controlBar: UIToolbar!
    @IBOutlet var backButton: UIBarButtonItem!
    @IBOutlet var actionButton: UIBarButtonItem!
    @IBOutlet var drawingSegmentedControl: UISegmentedControl!
    @IBOutlet var strokeSizeSlider: UISlider!
    @IBOutlet var infoView: AutoHideView!
    @IBOutlet var infoLabel: UILabel!
    @IBOutlet var strokeSizeView: StrokeSizeView!
    @IBOutlet var controlBarBottomConstraint: NSLayoutConstraint!
    
    //MARK: - VC Delegate
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        strokeSizeView.alpha = 0
        strokeSizeView.layer.cornerRadius = 10
        strokeSizeView.layer.borderColor = UIColor.white.cgColor
        strokeSizeView.layer.borderWidth = 1
        strokeSizeView.clipsToBounds = true
        
        drawingSegmentedControl.selectedSegmentIndex = 1
        SettingsController.sharedController.disableEraser()
        
        infoView.alpha = 0
        infoView.layer.cornerRadius = 10
        infoView.layer.borderColor = UIColor.white.cgColor
        infoView.layer.borderWidth = 1
        
        strokeSizeSlider.setValue(SettingsController.sharedController.currentStrokeWidth(), animated: false)
        strokeSizeSlider.setMinimumTrackImage(UIImage(named: "slider"), for: UIControlState())
        strokeSizeSlider.setMaximumTrackImage(UIImage(named: "slider"), for: UIControlState())
        strokeSizeSlider.setThumbImage(UIImage(named: "knob"), for: UIControlState())
        
        actionButton.target = self
        actionButton.action = #selector(CanvasViewController.actionButtonPressed)
    }
    
    override func viewWillLayoutSubviews() {
        if !hasBeingInitiallySetup {
            hasBeingInitiallySetup = true
            view.insertSubview(GridView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)), belowSubview: controlBar)
            
            scrollView = UIScrollView(frame: view.bounds)
            scrollView.delegate = self
            scrollView.panGestureRecognizer.minimumNumberOfTouches = 2
            view.insertSubview(scrollView, belowSubview: controlBar)
            
            setUpWithSize(kDefaultCanvasSize)
        }
    }
    
    func setUpWithSize(_ size: CGSize) {
        canvas?.removeFromSuperview()
        canvas = nil
        
        canvas = DrawableView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        canvas.layer.magnificationFilter = kCAFilterLinear
        canvas.center = view.center
        canvas.isUserInteractionEnabled = true
        canvas.alpha = 0.0

        scrollView.addSubview(canvas)
        scrollView.contentSize = canvas.bounds.size
        
        let scrollViewFrame = scrollView.frame
        let scaleWidth = scrollViewFrame.size.width / scrollView.contentSize.width
        let scaleHeight = scrollViewFrame.size.height / scrollView.contentSize.height
        let minScale = min(scaleWidth, scaleHeight);
        scrollView.minimumZoomScale = minScale;
        
        let canvasTransformValue = view.frame.width / canvas.frame.width
        canvas.transform = CGAffineTransform(scaleX: canvasTransformValue, y: canvasTransformValue)
        
        scrollView.maximumZoomScale = 12.5
        scrollView.minimumZoomScale = 0.25
        scrollView.zoomScale = minScale;
        
        centerScrollViewContents()
        
        UIView.animate(withDuration: 0.25, animations: {
            self.canvas.alpha = 1.0
        })
    }
    
    //MARK: - Actions
    @objc private func actionButtonPressed() {
        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        ac.addAction(
            UIAlertAction(title: "Share", style: .default) { action in
                let activityViewcontroller = UIActivityViewController(activityItems: ["Made with Doodler", URL(string: "http://apple.co/1IUYyFk")!, self.canvas.imageByCapturing], applicationActivities: nil)
                activityViewcontroller.excludedActivityTypes = [
                    UIActivityTypeAssignToContact, UIActivityTypeAddToReadingList, UIActivityTypePrint
                ]
                
                self.present(activityViewcontroller, animated: true, completion: {})
            }
        )
        ac.addAction(
            UIAlertAction(title: "Select Color", style: .default) { action in
                MenuController.sharedController.colorPickerVC.delegate = self
                self.present(StyledNavigationController(rootViewController: MenuController.sharedController.colorPickerVC), animated: true, completion: nil)
            }
        )
        if canvas.history.canReset {
            ac.addAction(
                UIAlertAction(title: "Clear Screen", style: .destructive) { action in
                    let alert = UIAlertController(title: "Clear Screen", message: "Would you like to clear the screen?", preferredStyle: .alert)
                    
                    alert.addAction(
                        UIAlertAction(title: "Clear", style: .destructive) { action in
                            self.canvas.clear()
                        }
                    )
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    
                    self.present(alert, animated: true, completion: nil)
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
    
    func clearScreen()
    {
    }
    
    @IBAction func drawingSegmentWasChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            SettingsController.sharedController.enableEraser()
        } else if sender.selectedSegmentIndex == 1 {
            SettingsController.sharedController.disableEraser()
        }
    }
    
    @IBAction func strokeSliderUpdated(_ sender: UISlider) {
        SettingsController.sharedController.setStrokeWidth(sender.value)
        strokeSizeView.strokeSize = CGFloat(sender.value)
        updateInfoForInfoView("Size: \(Int(sender.value))")
    }
    
    //MARK: - Helper Functions
    func updateInfoForInfoView(_ info: String) {
        infoLabel.text = info
        infoView.show()
    }
    
    func showToolbar() {
        controlBarBottomConstraint.constant = 0
        
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.05, initialSpringVelocity: 0.125, options: [], animations: {
            self.view.layoutIfNeeded()
        },
        completion: nil)
    }
    
    func hideToolbar() {
        controlBarBottomConstraint.constant = -controlBar.bounds.height
        
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
    
    func showMessageBannerWithText(_ text: String, color: UIColor, completion: (() -> Void)?) {
        let bannerHeight: CGFloat = 54.0
        let banner = UIView(frame: CGRect(x: 0, y: -bannerHeight - 25, width: self.view.frame.size.width, height: bannerHeight * 2))
        banner.backgroundColor = color
        
        let label = UILabel(frame: CGRect(x: 0, y: 13, width: banner.frame.width, height: (bannerHeight * 2)))
        label.textAlignment = .center
        label.text = text
        label.font = UIFont(name: "AvenirNext-Medium", size: 37.0)
        label.textColor = UIColor(hex: 0xecf0f1)
        banner.addSubview(label)
        self.view.addSubview(banner)
        let b = banner.bounds
        UIView.animate(withDuration: 0.93, delay: 0.0, usingSpringWithDamping: 0.3, initialSpringVelocity: 5.0, options: .curveEaseOut, animations: { () -> Void in
            banner.center = CGPoint(x: b.origin.x + b.size.width/2, y: bannerHeight/2)
        }) { _ in
            UIView.animate(withDuration: 0.93, delay: 0.69, usingSpringWithDamping: 0.7, initialSpringVelocity: 4.0, options: .curveEaseIn, animations: { () -> Void in
                banner.center = CGPoint(x: b.origin.x + b.size.width/2, y: -bannerHeight)
                }) { _ in
                    completion!()
                    banner.removeFromSuperview()
            }
        }
    }
    
    //MARK: - UIScrollViewDelegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return canvas
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let scale = Int(scrollView.zoomScale * 100)
        updateInfoForInfoView("\(scale)%")
        
        if lastCanvasZoomScale < scale && scrollView.pinchGestureRecognizer?.velocity > 2 {
            hideToolbar()
        }
        else if lastCanvasZoomScale > scale && scrollView.pinchGestureRecognizer?.velocity < -1 {
            showToolbar()
        }
        
        if scale > 750 {
            canvas.layer.magnificationFilter = kCAFilterNearest
        } else {
            canvas.layer.magnificationFilter = kCAFilterLinear
        }
        
        lastCanvasZoomScale = scale
        
        centerScrollViewContents()
    }
    
    //MARK: - ColorPickerViewControllerDelegate Methods -
    func colorPickerViewControllerDidPickColor(_ color: UIColor) {
        SettingsController.sharedController.setStrokeColor(color)
    }
    
    //MARK: - Motion Event Delegate
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            clearScreen()
        }
    }
}

