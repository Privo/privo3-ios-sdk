//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 23.06.2021.
//

import UIKit

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
    public func showAlert(title: String?, message: String?, acceptText: String, cancelText: String, acceptAction: @escaping () -> Void) {

        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let primaryButton = UIAlertAction(title: acceptText, style: .default) { _ in
            acceptAction()
        }

        let cancelButton = UIAlertAction(title: cancelText, style: .cancel, handler: nil)

        alertController.addAction(primaryButton)
        alertController.addAction(cancelButton)

        self.topMostViewController()?.present(alertController, animated: true)
    }
}