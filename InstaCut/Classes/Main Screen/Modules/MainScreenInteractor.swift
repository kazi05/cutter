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

class MainScreenInteractor: MainScreenInteractorInput {
    
    var photoLibraryManager: PhotoLibraryProtocol!
    
    func fetchAllVideosFromPhotoLibrary(_ view: UIViewController) {
        photoLibraryManager.fetchVideosFromPhotolibrary(view) { (error, videos) in
            //TODO
            print(videos)
            print(error ?? "succes")
        }
    }
    
}
