//
//  UIViewController+Ext.swift
//  InstaCut
//
//  Created by Kazim Gadjiev on 18.10.2020.
//  Copyright © 2020 Kazim Gajiev. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showAlert(with title: String,
                   body: String? = nil,
                   actionButton: UIAlertAction,
                   cancelButton: UIAlertAction = UIAlertAction(title: String.localized("CANCEL_BUTTON"), style: .cancel, handler: nil)) {
        let alert = UIAlertController(title: title, message: body, preferredStyle: .alert)
        alert.addAction(actionButton)
        alert.addAction(cancelButton)
        present(alert, animated: true, completion: nil)
    }
    
    func showSimpleAlert(with title: String,
                   body: String? = nil,
                   okAction: UIAlertAction = UIAlertAction(title: "Ок", style: .cancel, handler: nil)) {
        let alert = UIAlertController(title: title, message: body, preferredStyle: .alert)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    func showErrorAlert(with message: String?) {
        showSimpleAlert(with: String.localized("ALERT_ERROR_TITLE"), body: message)
    }
    
}
