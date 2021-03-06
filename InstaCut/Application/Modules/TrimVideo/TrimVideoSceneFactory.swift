//
//  TrimVideoSceneFactory.swift
//  InstaCut
//
//  Created by Kazim Gadjiev on 12.10.2020.
//  Copyright © 2020 Kazim Gajiev. All rights reserved.
//

import UIKit

struct TrimVideoSceneFactory {
    
    static func makeTrimmerScene(video: VideoModel,
                                 delegate: TrimVideoPresenterOutput
    ) -> (TrimVideoViewController, TrimVideoPresenterInput) {
        let viewController = TrimVideoViewController()
        let presenter = TrimVideoPresenter(view: viewController, delegate: delegate, video: video)
        viewController.presenter = presenter
        return (viewController, presenter)
    }
    
    static func makeTrimingProgressScene(video: VideoModel,
                                         periods: [VideoPeriod],
                                         settings: VideoRenderSettings,
                                         delegate: TrimmingProgressPresenterOutput
    ) -> TrimmingProgressViewController {
        let viewController = TrimmingProgressViewController()
        let presenter = TrimmingProgressPresenter(view: viewController, video: video, periods: periods, renderSettings: settings, delegate: delegate)
        viewController.presenter = presenter
        return viewController
    }
    
    static func makePurchaseNoMaskScene(product: IAPProduct,
                                        period: VideoPeriod,
                                        delegate: PurchasePresenterOutput
    ) -> PurchaseViewController {
        let viewController = PurchaseViewController()
        let noMaskPurchaseView = NoMaskPurchaseView.loadFromNib()
        noMaskPurchaseView.setPreview(from: period)
        let presenter = PurchasePresenter(view: viewController, delegate: delegate, product: product, preview: noMaskPurchaseView, description: .localized("NO_MASK_VC_DESRIPTION"))
        viewController.presenter = presenter
        return viewController
    }
    
    static func makePurchaseProgressBarScene(product: IAPProduct,
                                             period: VideoPeriod,
                                             delegate: PurchasePresenterOutput
    ) -> PurchaseViewController {
        let viewController = PurchaseViewController()
        let progressBarView = ProgressBarPurchaseView.loadFromNib()
        progressBarView.setPreview(from: period)
        let presenter = PurchasePresenter(view: viewController, delegate: delegate, product: product, preview: progressBarView, description: .localized("PROGRESS_BAR_DESCRIPTION"))
        viewController.presenter = presenter
        return viewController
    }
    
    static func makeColorPickerViewController(color: UIColor?,
                                              delegate: ProgressColorPickerPresenterOutput
    ) -> ProgressColorPickerController {
        let viewController = ProgressColorPickerController()
        let presenter = ProgressColorPickerPresenter(view: viewController, delegate: delegate, color: color)
        viewController.presenter = presenter
        return viewController
    }
}
