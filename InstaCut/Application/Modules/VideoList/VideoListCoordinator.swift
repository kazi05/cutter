//
//  VideoListCoordinator.swift
//  InstaCut
//
//  Created by Kazim Gadjiev on 12.10.2020.
//  Copyright © 2020 Kazim Gajiev. All rights reserved.
//

import UIKit

class VideoListCoordinator: Coordinator {

    var navigationController: UINavigationController?
    var childCoordinators: [Coordinator]?
    
    init(navigationController: UINavigationController?, childCoordinators: [Coordinator]? = nil) {
        self.navigationController = navigationController
        self.childCoordinators = childCoordinators
    }
    
    func start(with params: Any?) {
        showFirstScene()
    }
}

extension VideoListCoordinator {
    func showFirstScene() {
        let scene = VideoListFactory.makeFirstScene(delegate: self)
        navigationController?.viewControllers = [scene]
    }
}

extension VideoListCoordinator: VideoListPresenterOutput {
    
    func showVideoTrimmer(by asset: VideoModel) {
        if let childs = childCoordinators, let trimCoordinator = childs.first as? TrimVideoCoordinator {
            trimCoordinator.start(with: asset)
        }
    }
    
}

