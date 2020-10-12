//
//  MainScreenRouting.swift
//  InstaCut
//
//  Created by Kazim Gajiev on 03/03/2019.
//  Copyright © 2019 Kazim Gajiev. All rights reserved.
//

import UIKit

protocol MainScreenRoutingUnput {
    func navigateToCutVideo()
    func passDataToCutVideo(video: VideoModel)
}

class MainScreenRouting: MainScreenRoutingUnput {
    
    weak var viewController: MainScreenViewController!
    
    func navigateToCutVideo() {
        viewController.closure = { video in
            self.viewController.passDataToCutVideo(video: video)
        }
    }
    
    //Navigate to another module
    func passDataToCutVideo(video: VideoModel) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let cutVideoViewController = sb.instantiateViewController(withIdentifier: "CutVideoVC") as! CutVideoViewController
        cutVideoViewController.presenter.saveSelectedVideoModel(video)
        self.viewController.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.viewController.navigationController?.pushViewController(cutVideoViewController, animated: true)
    }
    
}
