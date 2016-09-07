
import UIKit

protocol ActionMenuViewControllerDelegate: class {
    func actionMenuViewControllerDidSelectShare(vc: ActionMenuViewController)
    func actionMenuViewControllerDidSelectClear(vc: ActionMenuViewController)
    func actionMenuViewControllerDidSelectUndo(vc: ActionMenuViewController)
    func actionMenuViewControllerDidSelectRedo(vc: ActionMenuViewController)
}

class ActionMenuViewController: UIViewController {
    
    fileprivate lazy var shareButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("Share", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(buttonPressed(sender:)), for: .touchUpInside)
        
        return button
    }()
    fileprivate lazy var clearButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("Clear", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(buttonPressed(sender:)), for: .touchUpInside)
        
        return button
    }()
    fileprivate lazy var undoButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("Undo", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(buttonPressed(sender:)), for: .touchUpInside)
        
        return button
    }()
    fileprivate lazy var redoButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("Redo", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(buttonPressed(sender:)), for: .touchUpInside)
        
        return button
    }()
    
    weak var delegate: ActionMenuViewControllerDelegate?
    
    var isPresentingWithinMessages = false
    
    var contentSize: CGSize {
        return view.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
    }
    
    init(isPresentingWithinMessages: Bool) {
        super.init(nibName: nil, bundle: nil)
        
        self.isPresentingWithinMessages = isPresentingWithinMessages
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.45)
        
        if !isPresentingWithinMessages { view.addSubview(shareButton) }
        view.addSubview(clearButton)
        view.addSubview(undoButton)
        view.addSubview(redoButton)
        
        var views = [String: Any]()
        if isPresentingWithinMessages {
            views = [
                "clear": clearButton,
                "undo": undoButton,
                "redo": redoButton
            ]
        }
        else {
            views = [
                "share": shareButton,
                "clear": clearButton,
                "undo": undoButton,
                "redo": redoButton
            ]
        }
        
        var formats = [
            isPresentingWithinMessages ? "V:|-[clear]-[undo]-|" : "V:|-[share]-[clear]-[undo]-|",
            "H:|[clear]|",
            "H:|[undo][redo]|"
        ]
        
        if !isPresentingWithinMessages {
            formats.append("H:|[share]|")
        }
        
        view.addConstraints(
            NSLayoutConstraint.constraints(
                with: formats,
                metrics: nil,
                views: views
            )
        )
        
        view.addConstraint(
            NSLayoutConstraint(
                item: redoButton,
                attribute: .centerY,
                relatedBy: .equal,
                toItem: undoButton,
                attribute: .centerY,
                multiplier: 1,
                constant: 0
            )
        )
        
        view.addConstraint(
            NSLayoutConstraint(
                item: undoButton,
                attribute: .width,
                relatedBy: .equal,
                toItem: nil,
                attribute: .notAnAttribute,
                multiplier: 1,
                constant: 90
            )
        )
        
        view.addConstraint(
            NSLayoutConstraint(
                item: redoButton,
                attribute: .width,
                relatedBy: .equal,
                toItem: undoButton,
                attribute: .width,
                multiplier: 1,
                constant: 0
            )
        )
    }
    
    // MARK: - Actions
    
    @objc fileprivate func buttonPressed(sender: UIButton) {
        switch sender {
            
        case shareButton:
            delegate?.actionMenuViewControllerDidSelectShare(vc: self)
            
        case clearButton:
            delegate?.actionMenuViewControllerDidSelectClear(vc: self)
            
        case undoButton:
            delegate?.actionMenuViewControllerDidSelectUndo(vc: self)
            
        case redoButton:
            delegate?.actionMenuViewControllerDidSelectRedo(vc: self)
            
        default:
            print("Failed to handle sender: \(sender).")
        }
    }
    
}
