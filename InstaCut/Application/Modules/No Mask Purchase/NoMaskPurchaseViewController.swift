//
//  NoMaskPurchaseViewController.swift
//  InstaCut
//
//  Created by Kazim Gadjiev on 16.10.2020.
//  Copyright © 2020 Kazim Gajiev. All rights reserved.
//

import UIKit

protocol NoMaskPurchaseView: class {
    
}

class NoMaskPurchaseViewController: UIViewController {
    
    // MARK: - Visible properties 👓
    var presenter: NoMaskPurchasePresenter!

    // MARK: - Outlets 🔌
    @IBOutlet weak var imageWithMask: UIImageView!
    @IBOutlet weak var imageWithoutMask: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - LifeCycle 🌎
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
    }
    
    // MARK: - Private methods 🕶
    private func configureUI() {        
        imageWithMask.image = presenter.getPeriodImage()
        imageWithoutMask.image = presenter.getPeriodImage()
        
        if let maskProduct = IAPManager.shared.getProduct(by: .mask) {
            buyButton.setTitle(.localized("NO_MASK_VC_BUY") + maskProduct.priceTitle, for: .normal)
        } else {
            buyButton.isHidden = true
        }
    }

    // MARK: - Actions ⚡️
    @IBAction func actionPurchaseNoMask(_ sender: Any) {
        buyButton.isHidden = true
        activityIndicator.startAnimating()
        
        IAPManager.shared.purchase(product: .mask) { [weak self] (state, error) in
            guard let self = self else { return }
            switch state {
            case .purchased:
                self.dismiss(animated: true, completion: nil)
                
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

extension NoMaskPurchaseViewController: NoMaskPurchaseView {
    
}
