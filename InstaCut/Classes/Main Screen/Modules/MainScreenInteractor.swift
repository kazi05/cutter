//
//  MainScreenViewControllerInteractor.swift
//  InstaCut
//
//  Created by Kazim Gajiev on 03/03/2019.
//  Copyright © 2019 Kazim Gajiev. All rights reserved.
//

import UIKit

protocol MainScreenInteractorInput: class {
    func fetchAllVideosFromPhotoLibrary(_ view: UIViewController)
}

protocol MainScreenInteractorOutput: class {
    func provideVideos(_ videos: [VideoModel])
    func accesError(_ error: String)
}

class MainScreenInteractor: MainScreenInteractorInput {
    
    weak var presenter: MainScreenInteractorOutput!
    var photoLibraryManager: PhotoLibraryProtocol!
    
    func fetchAllVideosFromPhotoLibrary(_ view: UIViewController) {
        photoLibraryManager.fetchVideosFromPhotolibrary(view) { (error, videos) in
            if let result = videos {
                self.presenter.provideVideos(result)
            }else if let err = error {
                self.presenter.accesError(err)
            }
        }
    }
    
}
