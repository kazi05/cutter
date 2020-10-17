//
//  PurchasePresenter.swift
//  InstaCut
//
//  Created by Kazim Gadjiev on 16.10.2020.
//  Copyright © 2020 Kazim Gajiev. All rights reserved.
//

import UIKit

class PurchasePresenter {
    
    // MARK: - Private properties 🕶
    private weak var view: PurchaseView!
    private let product: IAPProduct
    private let preview: UIView
    private let description: String
    
    // MARK: - Constructor 🏗
    init(view: PurchaseView, product: IAPProduct, preview: UIView, description: String) {
        self.view = view
        self.product = product
        self.preview = preview
        self.description = description
    }
    
    // MARK: - View actions
    func loadInfo() {
        view.configPurchaseInfo(description: description, priceTitle: product.priceTitle)
        view.setPreview(view: preview)
    }
    
}
