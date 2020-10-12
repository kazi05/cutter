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
    
    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
    
    func start() {
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
        let scene = VideoListFactory.makeTrimmerScene(video: asset)
        navigationController?.pushViewController(scene, animated: true)
    }
    
}

