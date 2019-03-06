//
//  CutVideoAssembly.swift
//  InstaCut
//
//  Created by Kazim Gajiev on 03/03/2019.
//  Copyright © 2019 Kazim Gajiev. All rights reserved.
//

import UIKit

class CutVideoAssembly {
    
    static let shared = CutVideoAssembly()
    
    func configure(_ viewController: CutVideoViewController) {
        let delegateVideoManager = DelegatingVideoHelper()
        let presenter = CutVideoPresenter()
        let interactor = CutVideoInteractor()
        viewController.presenter = presenter
        
        presenter.viewController = viewController
        presenter.interactor = interactor
        
        interactor.presenter = presenter
        interactor.delegateVideoManager = delegateVideoManager
    }
    
}
