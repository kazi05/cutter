//
//  PurchaseViewController.swift
//  InstaCut
//
//  Created by Kazim Gadjiev on 16.10.2020.
//  Copyright © 2020 Kazim Gajiev. All rights reserved.
//

import UIKit

protocol PurchaseView: class {
    func setPreview(view: UIView)
    func configPurchaseInfo(description: String, priceTitle: String)
}

class PurchaseViewController: UIViewController {
    
    // MARK: - Visible properties 👓
    var presenter: PurchasePresenter!

    // MARK: - Outlets 🔌
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var previewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageWithMask: UIImageView!
    @IBOutlet weak var imageWithoutMask: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - LifeCycle 🌎
    override func viewDidLoad() {
        super.viewDidLoad()

        presenter.loadInfo()
    }

    // MARK: - Actions ⚡️
    @IBAction func actionPurchaseProduct(_ sender: Any) {
        buyButton.isHidden = true
        activityIndicator.startAnimating()
        
        IAPManager.shared.purchase(product: presenter.getProdcut().kind) { [weak self] (state, error) in
            guard let self = self else { return }
            switch state {
            case .purchased:
                self.dismiss(animated: true) { [weak self] in
                    self?.presenter.purchaseSuccess()
                }
                
            default:
                self.buyButton.isHidden = false
                self.activityIndicator.stopAnimating()
                
                if let error = error {
                    self.showErrorAlert(with: error.localizedDescription)
                }
            }
        }
    }
    
    @IBAction func actionCancel(_ sender: Any) {
        dismiss(animated: true)
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
