//
//  PurchaseViewController.swift
//  InstaCut
//
//  Created by Kazim Gadjiev on 16.10.2020.
//  Copyright © 2020 Kazim Gajiev. All rights reserved.
//

import UIKit
import StoreKit

protocol PurchaseView: class {
    func setPreview(view: UIView)
    func configPurchaseInfo(description: String, priceTitle: String)
}

class PurchaseViewController: UIViewController {
    
    // MARK: - Visible properties 👓
    var presenter: PurchasePresenter!
    
    private let iapManager = IAPManager.shared

    // MARK: - Outlets 🔌
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var previewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var restoreButton: UIButton!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - LifeCycle 🌎
    override func viewDidLoad() {
        super.viewDidLoad()

        presenter.loadInfo()
    }

    // MARK: - Actions ⚡️
    @IBAction func actionPurchaseProduct(_ sender: Any) {
        hidePurchaseButtons()
        
        iapManager.purchase(product: presenter.getProdcut().kind) { [weak self] (state, error) in
            self?.purchaseCompleted(state: state, error: error)
        }
    }
    
    @IBAction func actionRestorePurchase(_ sender: Any) {
        hidePurchaseButtons()
        
        iapManager.restorePurchases { [weak self] (state, error) in
            self?.purchaseCompleted(state: state, error: error)
        }
    }
    
    @IBAction func actionCancel(_ sender: Any) {
        dismiss(animated: true)
    }
}

// MARK: - Private methods
fileprivate extension PurchaseViewController {
    
    func hidePurchaseButtons() {
        buyButton.isHidden = true
        restoreButton.isHidden = true
        activityIndicator.startAnimating()
    }
    
    func showPurchaseButtons() {
        restoreButton.isHidden = false
        buyButton.isHidden = false
        activityIndicator.stopAnimating()
    }
    
    func purchaseCompleted(state: SKPaymentTransactionState, error: Error?) {
        switch state {
        case .purchased, .restored:
            self.dismiss(animated: true) { [weak self] in
                self?.presenter.purchaseSuccess()
            }
            
        default:
            self.showPurchaseButtons()
            
            if let error = error {
                self.showErrorAlert(with: error.localizedDescription)
            }
        }
    }
    
}

// MARK: - View methods
extension PurchaseViewController: PurchaseView {
    func configPurchaseInfo(description: String, priceTitle: String) {
        descriptionLabel.text = description
        buyButton.setTitle(.localized("NO_MASK_VC_BUY") + priceTitle, for: .normal)
    }
    
    func setPreview(view: UIView) {
        previewView.addSubview(view)
        view.frame = previewView.bounds
    }
    
}
