//
//  AlertTransitioningDelegate.swift
//  InstaCut
//
//  Created by Kazim Gadjiev on 14.10.2020.
//  Copyright © 2020 Kazim Gajiev. All rights reserved.
//

import UIKit

final class AlertTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    var alertHeight: CGFloat
    
    init(alertHeight: CGFloat) {
        self.alertHeight = alertHeight
        super.init()
    }
    
    // MARK: - UIViewControllerTransitioningDelegate
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return AlertModalPresentationController(alertHeight: alertHeight, presentedViewController: presented, presenting: presenting)
    }
}


