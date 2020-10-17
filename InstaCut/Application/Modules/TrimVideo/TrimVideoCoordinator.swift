//
//  TrimVideoCoordinator.swift
//  InstaCut
//
//  Created by Kazim Gadjiev on 12.10.2020.
//  Copyright © 2020 Kazim Gajiev. All rights reserved.
//

import UIKit

class TrimVideoCoordinator: Coordinator {

    var navigationController: UINavigationController?
    var childCoordinators: [Coordinator]?
    
    init(navigationController: UINavigationController?, childCoordinators: [Coordinator]? = nil) {
        self.navigationController = navigationController
        self.childCoordinators = childCoordinators
    }
    
    func start(with params: Any?) {
        guard let asset = params as? VideoModel else { return }
        showFirstScene(with: asset)
    }
}

fileprivate extension TrimVideoCoordinator {
    
    func showFirstScene(with asset: VideoModel) {
        let scene = TrimVideoSceneFactory.makeTrimmerScene(video: asset, delegate: self)
        navigationController?.pushViewController(scene, animated: true)
    }
}

extension TrimVideoCoordinator: TrimVideoPresenterOutput {
    
    func saveVideos(from video: VideoModel, with periods: [VideoPeriod], and settings: VideoRenderSettings) {
        let scene = TrimVideoSceneFactory.makeTrimingProgressScene(video: video, periods: periods, settings: settings, delegate: self)
        let alert = CustomAlertController(viewController: scene)
        navigationController?.present(alert, animated: true)
    }
    
    func purchaseNoMask(product: IAPProduct, period: VideoPeriod) {
        let scene = TrimVideoSceneFactory.makePurchaseNoMaskScene(product: product, period: period)
        let alert = CustomAlertController(viewController: scene)
        navigationController?.present(alert, animated: true)
    }
    
    func purchaseProgressBar(product: IAPProduct, period: VideoPeriod) {
        
    }
    
}

extension TrimVideoCoordinator: TrimmingProgressPresenterOutput {
    
}
