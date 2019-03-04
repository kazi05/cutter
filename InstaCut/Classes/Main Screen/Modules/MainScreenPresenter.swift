//
//  MainScreenViewControllerPresenter.swift
//  InstaCut
//
//  Created by Kazim Gajiev on 03/03/2019.
//  Copyright © 2019 Kazim Gajiev. All rights reserved.
//

import UIKit

protocol MainScreenPresenterInput: MainScreenViewControllerOutput, MainScreenInteractorOutput {
    
}

class MainScreenPresenter: MainScreenPresenterInput {
    
    weak var view: MainScreenViewControllerInput!
    var interactor: MainScreenInteractorInput!
    
    //Presenter says interactor ViewController needs videos
    func fetchVideos(_ view: UIViewController) {
        interactor.fetchAllVideosFromPhotoLibrary(view)
    }
    
    //Interactor return result of videos
    func provideVideos(_ videos: [VideoModel]) {
        self.view.displayFetchedVideos(videos)
    }
    
    //Show error from interactor
    func accesError(_ error: String) {
        self.view.displayAccesError(error: error)
    }
    
    //Show CutVideo Screen
    func gotoCutVideoScreen() {
        
    }
    
}
