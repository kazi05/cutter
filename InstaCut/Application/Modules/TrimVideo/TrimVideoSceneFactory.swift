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
    ) -> TrimVideoViewController {
        let viewController = TrimVideoViewController()
        let presenter = TrimVideoPresenter(view: viewController, delegate: delegate, video: video)
        viewController.presenter = presenter
        return viewController
    }
    
    static func makeTrimingProgressScene(video: VideoModel,
                                         periods: [VideoPeriod],
                                         delegate: TrimmingProgressPresenterOutput
    ) -> TrimmingProgressViewController {
        let viewController = TrimmingProgressViewController()
        let presenter = TrimmingProgressPresenter(view: viewController, video: video, periods: periods, delegate: delegate)
        viewController.presenter = presenter
        return viewController
    }
    
    static func makePurchaseNoMaskScene(period: VideoPeriod) -> NoMaskPurchaseViewController {
        let viewController = NoMaskPurchaseViewController()
        let presenter = NoMaskPurchasePresenter(view: viewController, period: period)
        viewController.presenter = presenter
        return viewController
    }
}
