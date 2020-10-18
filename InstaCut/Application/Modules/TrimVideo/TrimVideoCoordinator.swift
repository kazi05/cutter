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
    
    private var trimVideoPresenterInput: TrimVideoPresenterInput!
    
    init(navigationController: UINavigationController?, childCoordinators: [Coordinator]? = nil) {
        self.navigationController = navigationController
        self.childCoordinators = childCoordinators
    }
    
    func start(with params: Any?) {
        guard let asset = params as? VideoModel else { return }
        showFirstScene(with: asset)
    }
}

// MARK: - Private methods
fileprivate extension TrimVideoCoordinator {
    
    func showFirstScene(with asset: VideoModel) {
        let (scene, input) = TrimVideoSceneFactory.makeTrimmerScene(video: asset, delegate: self)
        self.trimVideoPresenterInput = input
        navigationController?.pushViewController(scene, animated: true)
    }
}

// MARK: - TrimVideoPresenterOutput methods
extension TrimVideoCoordinator: TrimVideoPresenterOutput {
    
    func saveVideos(from video: VideoModel, with periods: [VideoPeriod], and settings: VideoRenderSettings) {
        let scene = TrimVideoSceneFactory.makeTrimingProgressScene(video: video, periods: periods, settings: settings, delegate: self)
        let alert = CustomAlertController(viewController: scene)
        navigationController?.present(alert, animated: true)
    }
    
    func purchaseNoMask(product: IAPProduct, period: VideoPeriod) {
        let scene = TrimVideoSceneFactory.makePurchaseNoMaskScene(product: product, period: period, delegate: self)
        let alert = CustomAlertController(viewController: scene)
        navigationController?.present(alert, animated: true)
    }
    
    func purchaseProgressBar(product: IAPProduct, period: VideoPeriod) {
        let scene = TrimVideoSceneFactory.makePurchaseProgressBarScene(product: product, period: period, delegate: self)
        let alert = CustomAlertController(viewController: scene)
        navigationController?.present(alert, animated: true)
    }
    
    func showColorPickerController(color: UIColor?) -> ProgressColorPickerController {
        return TrimVideoSceneFactory.makeColorPickerViewController(color: color, delegate: self)
    }
}

// MARK: - TrimmingProgressPresenterOutput methods
extension TrimVideoCoordinator: TrimmingProgressPresenterOutput {
    
}

// MARK: - PurchasePresenterOutput methods
extension TrimVideoCoordinator: PurchasePresenterOutput {
    
    func productPurchaseSuccess(_ product: IAPProduct) {
        trimVideoPresenterInput.purchaseCompleted(product)
    }
    
}

// MARK: - ProgressColorPickerPresenterOutput methods
extension TrimVideoCoordinator: ProgressColorPickerPresenterOutput {
    
    func colorChanged(_ color: UIColor) {
        trimVideoPresenterInput.progressColorChanged(color)
    }
    
    func colorChoosed(_ color: UIColor) {
        trimVideoPresenterInput.progressColorChoosed(color)
    }
    
    func colorRemoved() {
        trimVideoPresenterInput.progressColorRemoved()
    }
    
    func canceled() {
        trimVideoPresenterInput.progressColorCanceled()
    }
    
}
