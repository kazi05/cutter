//
//  VideoListFactory.swift
//  InstaCut
//
//  Created by Kazim Gadjiev on 12.10.2020.
//  Copyright © 2020 Kazim Gajiev. All rights reserved.
//

import UIKit

struct VideoListFactory {
    
    static func makeFirstScene(delegate: VideoListPresenterOutput?) -> VideoListViewController {
        let viewController = VideoListViewController()
        let presenter = VideoListPresenter(view: viewController, delegate: delegate)
        viewController.presenter = presenter
        return viewController
    }
    
    static func makeTrimmerScene(video: VideoModel) -> TrimVideoViewController {
        let viewController = TrimVideoViewController()
        let presenter = TrimVideoPresenter(view: viewController, video: video)
        viewController.presenter = presenter
        return viewController
    }
}
