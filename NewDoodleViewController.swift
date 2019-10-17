
import UIKit

protocol NewDoodleViewControllerDelegate: class {
    func newDoodleViewControllerDidComplete(with size: CGSize)
}

class NewDoodleViewController: UIViewController {
    
    @IBOutlet var aspectView: AspectPreviewView!
    @IBOutlet var widthTextField: UITextField!
    @IBOutlet var heightTextField: UITextField!
    @IBOutlet var formContainerView: UIView!
    @IBOutlet var aspectSwitch: UISwitch!
    
    weak var delegate: NewDoodleViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "New Doodle"
        navigationItem.largeTitleDisplayMode = .never
        
        aspectSwitch.onTintColor = .doodlerRed
        widthTextField.tintColor = .doodlerRed
        heightTextField.tintColor = .doodlerRed
        formContainerView.layer.cornerRadius = 5
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: NSLocalizedString("CANCEL", comment: "Cancel"),
            style: .plain,
            target: self,
            action: #selector(cancelButtonPressed)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: NSLocalizedString("CREATE", comment: "Create"),
            style: .plain,
            target: self,
            action: #selector(createButtonPressed)
        )
                
        widthTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        heightTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        let width: CGFloat, height: CGFloat
        
        if let lastSize = SettingsController.shared.documentSize {
            width = lastSize.width
            height = lastSize.height
        }
        else {
            let screenSize = UIScreen.main.bounds.size
            width = screenSize.width
            height = screenSize.height
        }
        
        widthTextField.text = String(Int(width))
        heightTextField.text = String(Int(height))
        
        aspectView.aspectRatio = width / height
    }
    
    // MARK: - Actions
    
    @objc private func cancelButtonPressed() {
        dismiss(animated: true)
    }
    
    @objc private func createButtonPressed() {
        guard let widthText = widthTextField.text, let width = Double(widthText) else {
            return
        }
        
        guard let heightText = heightTextField.text, let height = Double(heightText) else {
            return
        }

        let selectedSize = CGSize(width: width, height: height)
        SettingsController.shared.documentSize = selectedSize
        
        dismiss(animated: true) {
            self.delegate?.newDoodleViewControllerDidComplete(with: selectedSize)
        }
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard let widthText = widthTextField.text, let width = Double(widthText) else {
            navigationItem.rightBarButtonItem?.isEnabled = false
            return
        }
        
        guard let heightText = heightTextField.text, let height = Double(heightText) else {
            navigationItem.rightBarButtonItem?.isEnabled = false
            return
        }
        
        if navigationItem.rightBarButtonItem?.isEnabled == false {
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
                
        guard aspectSwitch.isOn else {
            aspectView.aspectRatio = CGFloat(width / height)
            return
        }
        
        if textField == widthTextField {
            heightTextField.text = String(Int(round(CGFloat(width) / aspectView.aspectRatio)))
        }
        else {
            widthTextField.text = String(Int(round(CGFloat(height) * aspectView.aspectRatio)))
        }
    }
    
}

extension NewDoodleViewController: NavigationPresentationConfigurable {
    
    var contentHeight: CGFloat {
        return 320
    }
    
}
