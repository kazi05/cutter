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

extension TrimVideoCoordinator {
    
    func showFirstScene(with asset: VideoModel) {
        let scene = TrimVideoSceneFactory.makeTrimmerScene(video: asset)
        navigationController?.pushViewController(scene, animated: true)
    }
}
