
import UIKit

class AppController: NSObject {
    
    static let sharedController = AppController()
    
    var presenterViewController: UIViewController?
    
    private var presentationManager: NavigationPresentationManager?
    
    lazy var doodlesNC: NavigationController = {
        return NavigationController(DoodlesViewController())
    }()
    
    private lazy var rootDocumentVC: UIDocumentBrowserViewController = {
        let vc = UIDocumentBrowserViewController(forOpeningFilesWithContentTypes: ["public.image", "net.naturaln0va.Doodler"])
        
        vc.additionalLeadingNavigationBarButtonItems = [UIBarButtonItem(
            image: UIImage(systemName: "gear"),
            style: .plain,
            target: self,
            action: #selector(settingsButtonPressed)
        )]
        vc.shouldShowFileExtensions = true
        vc.defaultDocumentAspectRatio = 1
        vc.allowsDocumentCreation = true
        vc.delegate = self

        return vc
    }()
                
    func showInWindow(_ window: UIWindow) {
        window.rootViewController = rootDocumentVC
        window.makeKeyAndVisible()
    }
    
    // MARK: - Actions
    
    @objc private func settingsButtonPressed() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        UIApplication.shared.open(settingsURL, options: [:])
    }

}

extension AppController: UIDocumentBrowserViewControllerDelegate {
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didRequestDocumentCreationWithHandler importHandler: @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void) {
        let vc = NewDoodleViewController()
        vc.delegate = self
        
        presentationManager = NavigationPresentationManager(viewController: vc)
        presentationManager?.present(from: controller)
        
        importHandler(nil, .none)
    }
    
}

extension AppController: NewDoodleViewControllerDelegate {
    
    func newDoodleViewControllerDidComplete(with size: CGSize) {
        let vc = CanvasViewController(size: size)
        vc.delegate = self
        vc.modalPresentationStyle = .fullScreen
        
        rootDocumentVC.present(vc, animated: true, completion: nil)
    }
    
}


extension AppController: CanvasViewControllerDelegate {
    
    func canvasViewControllerShouldDismiss(_ vc: CanvasViewController, didSave: Bool) {
        vc.dismiss(animated: true)
    }
    
}
