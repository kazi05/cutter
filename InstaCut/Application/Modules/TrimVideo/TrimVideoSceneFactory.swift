//
//  TrimVideoSceneFactory.swift
//  InstaCut
//
//  Created by Kazim Gadjiev on 12.10.2020.
//  Copyright © 2020 Kazim Gajiev. All rights reserved.
//

import UIKit

struct TrimVideoSceneFactory {
    
    static func makeTrimmerScene(video: VideoModel) -> TrimVideoViewController {
        let viewController = TrimVideoViewController()
        let presenter = TrimVideoPresenter(view: viewController, video: video)
        viewController.presenter = presenter
        return viewController
    }
    
}
