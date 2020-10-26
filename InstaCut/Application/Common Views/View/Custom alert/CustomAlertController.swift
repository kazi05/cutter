//
//  CustomAlertController.swift
//  InstaCut
//
//  Created by Kazim Gadjiev on 14.10.2020.
//  Copyright © 2020 Kazim Gajiev. All rights reserved.
//

import UIKit

class CustomAlertController: UIViewController {

    // MARK: - Public properties
    
    private(set) var viewController: UIViewController!
    
    public var alertHeight: CGFloat?
    
    // MARK: - Private properties
    
    private var alertTransitioningDelegate: AlertTransitioningDelegate!
    
    private var alertView: UIView!
    
    convenience init() {
        self.init(viewController: nil)
    }
    
    init(alertHeight: CGFloat? = nil, viewController: UIViewController? = nil, alertView: UIView? = nil) {
        self.alertHeight = alertHeight
        self.viewController = viewController
        super.init(nibName: nil, bundle: nil)
        if viewController != nil {
            self.alertView = viewController?.view
        } else {
            self.alertView = alertView
        }
        
        if viewController != nil || alertView != nil {
            setupAlertHeight()
        }
    }
    
    required init?(coder: NSCoder) {
        self.alertHeight = 0
        super.init(coder: coder)
    }

}

// MARK: - Public methods

extension CustomAlertController {
    
    public func setViewController(viewController: UIViewController) {
        self.viewController = viewController
        self.alertView = viewController.view
        setupAlertHeight()
    }
    
    public func setAlertView(view: UIView) {
        self.alertView = view
        setupAlertHeight()
    }
    
}

// MARK: - Configure view controller

fileprivate  extension CustomAlertController {
    
    func setupAlertHeight() {
        modalPresentationStyle = .custom
        
        if viewController != nil {
            setupViewController()
        } else {
            setupAlertView()
        }
        
        let rootTargetSize = CGSize(width: alertView.bounds.width,
                                height: UIView.layoutFittingCompressedSize.height)
        let rootHeight = alertView.systemLayoutSizeFitting(rootTargetSize).height
        
        alertTransitioningDelegate = AlertTransitioningDelegate(alertHeight: alertHeight ?? rootHeight)
        transitioningDelegate = alertTransitioningDelegate
    }
    
    func setupViewController() {
        addChild(viewController)
        
        setupAlertView()
        
        viewController.didMove(toParent: self)
        
    }
    
    func setupAlertView() {
        precondition(alertView != nil, "Alert view was not set")
        alertView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(alertView)
        
        NSLayoutConstraint.activate([
            alertView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            alertView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            alertView.topAnchor.constraint(equalTo: view.topAnchor),
            alertView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

