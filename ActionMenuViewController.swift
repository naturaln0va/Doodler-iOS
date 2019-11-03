
import UIKit

protocol ActionMenuViewControllerDelegate: class {
    func actionMenuViewControllerDidSelectShare(vc: ActionMenuViewController)
    func actionMenuViewControllerDidSelectClear(vc: ActionMenuViewController)
    func actionMenuViewControllerDidSelectUndo(vc: ActionMenuViewController)
    func actionMenuViewControllerDidSelectRedo(vc: ActionMenuViewController)
}

class ActionMenuViewController: UIViewController {
    
    private lazy var shareButton: UIButton = {
        let button = UIButton()
        
        button.setTitleColor(UIColor(white: 1, alpha: 0.5), for: .highlighted)
        button.setTitle(NSLocalizedString("SHARE", comment: "Share"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(buttonPressed(sender:)), for: .touchUpInside)
        
        return button
    }()
    private lazy var clearButton: UIButton = {
        let button = UIButton()
        
        button.setTitleColor(UIColor(white: 1, alpha: 0.5), for: .highlighted)
        button.setTitle(NSLocalizedString("CLEAR", comment: "Clear"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(buttonPressed(sender:)), for: .touchUpInside)
        
        return button
    }()
    private lazy var undoButton: UIButton = {
        let button = UIButton()
        
        button.setTitleColor(UIColor(white: 1, alpha: 0.5), for: .highlighted)
        button.setTitle(NSLocalizedString("UNDO", comment: "Undo"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(buttonPressed(sender:)), for: .touchUpInside)
        
        return button
    }()
    private lazy var redoButton: UIButton = {
        let button = UIButton()
        
        button.setTitleColor(UIColor(white: 1, alpha: 0.5), for: .highlighted)
        button.setTitle(NSLocalizedString("REDO", comment: "Redo"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(buttonPressed(sender:)), for: .touchUpInside)
        
        return button
    }()
    
    weak var delegate: ActionMenuViewControllerDelegate?
    
    var isPresentingWithinMessages = false
    
    var drawableView: DrawableView? {
        didSet {
            if let drawable = drawableView {
                let undoColor = drawable.history.canUndo ? .white : UIColor(white: 1, alpha: 0.5)
                undoButton.setTitleColor(undoColor, for: .normal)
                
                let redoColor = drawable.history.canRedo ? .white : UIColor(white: 1, alpha: 0.5)
                redoButton.setTitleColor(redoColor, for: .normal)
            }
        }
    }
    
    var contentSize: CGSize {
        let size = view.systemLayoutSizeFitting(UIView.layoutFittingExpandedSize)
        return CGSize(width: max(175, size.width), height: size.height)
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
        
        let topSeperatorView = UIView()
        topSeperatorView.backgroundColor = .white
        topSeperatorView.translatesAutoresizingMaskIntoConstraints = false
        
        let bottomSeperatorView = UIView()
        bottomSeperatorView.backgroundColor = .white
        bottomSeperatorView.translatesAutoresizingMaskIntoConstraints = false

        let middleSeperatorView = UIView()
        middleSeperatorView.backgroundColor = .white
        middleSeperatorView.translatesAutoresizingMaskIntoConstraints = false

        if !isPresentingWithinMessages {
            view.addSubview(shareButton)
            view.addSubview(topSeperatorView)
        }
        view.addSubview(clearButton)
        view.addSubview(bottomSeperatorView)
        view.addSubview(undoButton)
        view.addSubview(middleSeperatorView)
        view.addSubview(redoButton)
        
        var views = [String: Any]()
        if isPresentingWithinMessages {
            views = [
                "clear": clearButton,
                "bottom": bottomSeperatorView,
                "undo": undoButton,
                "mid": middleSeperatorView,
                "redo": redoButton
            ]
        }
        else {
            views = [
                "share": shareButton,
                "top": topSeperatorView,
                "clear": clearButton,
                "bottom": bottomSeperatorView,
                "undo": undoButton,
                "mid": middleSeperatorView,
                "redo": redoButton
            ]
        }
        
        var formats = [
            isPresentingWithinMessages ? "V:|-[clear][bottom(==scale)][undo]-|" : "V:|-[share][top(==scale)][clear][bottom(==scale)][undo]-|",
            "H:|[clear]|",
            "H:|[bottom]|",
            "H:|[undo][mid(==scale)][redo]|"
        ]
        
        if !isPresentingWithinMessages {
            formats.append("H:|[share]|")
            formats.append("H:|[top]|")
        }
        
        view.addConstraints(
            NSLayoutConstraint.constraints(
                with: formats,
                metrics: ["scale": 1 / UIScreen.main.scale],
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
                item: middleSeperatorView,
                attribute: .centerY,
                relatedBy: .equal,
                toItem: undoButton,
                attribute: .centerY,
                multiplier: 1,
                constant: 0
            )
        )
        
        if !isPresentingWithinMessages {
            view.addConstraint(
                NSLayoutConstraint(
                    item: undoButton,
                    attribute: .height,
                    relatedBy: .equal,
                    toItem: shareButton,
                    attribute: .height,
                    multiplier: 1,
                    constant: 0
                )
            )
        }
        view.addConstraint(
            NSLayoutConstraint(
                item: undoButton,
                attribute: .height,
                relatedBy: .equal,
                toItem: clearButton,
                attribute: .height,
                multiplier: 1,
                constant: 0
            )
        )
        view.addConstraint(
            NSLayoutConstraint(
                item: undoButton,
                attribute: .height,
                relatedBy: .equal,
                toItem: middleSeperatorView,
                attribute: .height,
                multiplier: 1,
                constant: 0
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
    
    @objc private func buttonPressed(sender: UIButton) {
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
