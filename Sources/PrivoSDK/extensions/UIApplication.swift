import UIKit
import SwiftUI

extension UIApplication {
    
    public func topMostViewController() -> UIViewController? {
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        if var topController = keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
        }
        return nil
    }
    
    public func showAlert(title: String?,
                          message: String?,
                          acceptText: String,
                          cancelText: String,
                          acceptAction: @escaping () -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let primaryButton = UIAlertAction(title: acceptText, style: .default) { _ in
            acceptAction()
        }
        let cancelButton = UIAlertAction(title: cancelText, style: .cancel, handler: nil)
        alertController.addAction(primaryButton)
        alertController.addAction(cancelButton)
        topMostViewController()?.present(alertController, animated: true)
    }
    
    public func showView<Content>(
        presentationStyle: UIModalPresentationStyle = .automatic,
        _ isTransparent: Bool,
        @ViewBuilder content: @escaping () -> Content
    ) where Content : View {
        Task.init(priority: .userInitiated) {
            let view = content()
            let viewController = UIHostingController(rootView: view)
            if (isTransparent) {
                viewController.view.backgroundColor = .clear
            }
            viewController.modalPresentationStyle = presentationStyle
            guard let topView = topMostViewController() else { return }
            topView.present(viewController, animated: true, completion: nil)
        }
    }
    
    public func dismissTopView() {
        Task.init(priority: .userInitiated) { @MainActor in
            topMostViewController()?.dismiss(animated: true, completion: nil)
        }
    }
    
}
