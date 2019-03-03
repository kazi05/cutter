//
//  MainScreenViewControllerPresenter.swift
//  InstaCut
//
//  Created by Kazim Gajiev on 03/03/2019.
//  Copyright © 2019 Kazim Gajiev. All rights reserved.
//

import UIKit

protocol MainScreenPresenterInput: MainScreenViewControllerOutput {
    
}

class MainScreenPresenter: MainScreenPresenterInput {
    
    var interactor: MainScreenInteractorInput!
    
    //Presenter says interactor ViewController needs videos
    func fetchVideos(_ view: UIViewController) {
        interactor.fetchAllVideosFromPhotoLibrary(view)
    }
    
}
