//
//  MainScreenAssembly.swift
//  InstaCut
//
//  Created by Kazim Gajiev on 03/03/2019.
//  Copyright © 2019 Kazim Gajiev. All rights reserved.
//

import UIKit

class MainScreenAssembly {
    
    static let shared = MainScreenAssembly()
    
    func configure(_ viewController: MainScreenViewController) {
        let photoLibraryManager = PhotoLibraryManager()
        let interactor = MainScreenInteractor()
        let presenter = MainScreenPresenter()
        let router = MainScreenRouting()
        
        viewController.presenter = presenter
        
        presenter.view = viewController
        presenter.interactor = interactor
        presenter.router = router
        
        interactor.presenter = presenter
        interactor.photoLibraryManager = photoLibraryManager
        
        router.viewController = viewController
    }
    
}
