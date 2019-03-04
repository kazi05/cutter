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
}

class MainScreenRouting {
    
    weak var viewController: MainScreenViewController!
    
    func navigateToCutVideo() {
        viewController.closure? = { (video) in
            print("Tapped video: \(video) ")
        }
    }
    
}
