//
//  NoMaskPurchasePresenter.swift
//  InstaCut
//
//  Created by Kazim Gadjiev on 16.10.2020.
//  Copyright © 2020 Kazim Gajiev. All rights reserved.
//

import UIKit

class NoMaskPurchasePresenter {
    
    // MARK: - Private properties 🕶
    private weak var view: NoMaskPurchaseView!
    private let period: VideoPeriod
    
    // MARK: - Constructor 🏗
    init(view: NoMaskPurchaseView, period: VideoPeriod) {
        self.view = view
        self.period = period
    }
    
    // MARK: - View actions
    func getPeriodImage() -> UIImage {
        return period.previewImage
    }
    
}
