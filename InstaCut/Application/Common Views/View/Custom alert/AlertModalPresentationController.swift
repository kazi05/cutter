//
//  AlertModalPresentationController.swift
//  InstaCut
//
//  Created by Kazim Gadjiev on 14.10.2020.
//  Copyright © 2020 Kazim Gajiev. All rights reserved.
//

import UIKit

enum ModalScaleState {
    case presentation
    case interaction
}

final class AlertModalPresentationController: UIPresentationController {
    
    private var alertHeight: CGFloat = 0
    private var direction: CGFloat = 0
    private var state: ModalScaleState = .interaction
    
    private lazy var dimmingView: UIView! = {
        guard let container = containerView else { return nil }
        
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = container.bounds
        blurView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(didTap(tap:)))
        )
        
        return blurView
    }()
    
    convenience init(alertHeight: CGFloat, presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        self.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        self.alertHeight = alertHeight
    }
    
    @objc private func didTap(tap: UITapGestureRecognizer) {
        presentedViewController.dismiss(animated: true, completion: nil)
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let container = containerView else { return .zero }
        return CGRect(x: 20, y: max(10, container.center.y - alertHeight / 2), width: container.bounds.width - 40, height: alertHeight)
    }
    
    override func presentationTransitionWillBegin() {
        guard let container = containerView,
            let coordinator = presentingViewController.transitionCoordinator else { return }
        
        dimmingView.alpha = 0
        container.addSubview(dimmingView)
        container.addSubview(presentedViewController.view)
        
        let view = presentedViewController.view
        let radius = container.bounds.width / 20
        view?.layer.cornerRadius = radius
        view?.clipsToBounds = true
        
        coordinator.animate(alongsideTransition: { [weak self] context in
            guard let self = self else { return }
            
            self.dimmingView.alpha = 1
            }, completion: nil)
    }
    
    override func dismissalTransitionWillBegin() {
        guard let coordinator = presentingViewController.transitionCoordinator else { return }
        
        coordinator.animate(alongsideTransition: { [weak self] (context) -> Void in
            guard let self = self else { return }
            
            self.dimmingView.alpha = 0
            self.presentedViewController.view?.frame.origin.y = self.containerView?.bounds.height ?? 0
            }, completion: nil)
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            dimmingView.removeFromSuperview()
        }
    }
    
    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)
        guard let containerView = containerView, let view = presentedView else { return }
        if alertHeight > 0 { return }
        
        let height = max(0, min(containerView.bounds.height, container.preferredContentSize.height))
        
        view.frame.size.height = height
        view.frame.origin.y = containerView.bounds.height - container.preferredContentSize.height
        alertHeight = height
    }
    
}

