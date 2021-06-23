//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 23.06.2021.
//

import UIKit

extension UIWindow {
    public func showAlert(title: String?, message: String?, acceptText: String, cancelText: String, acceptAction: @escaping () -> Void) {

        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let primaryButton = UIAlertAction(title: acceptText, style: .default) { _ in
            acceptAction()
        }

        let cancelButton = UIAlertAction(title: cancelText, style: .cancel, handler: nil)

        alertController.addAction(primaryButton)
        alertController.addAction(cancelButton)

        self.rootViewController?.present(alertController, animated: true)
    }
}
