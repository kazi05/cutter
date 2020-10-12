//
//  VideoListPresenter.swift
//  InstaCut
//
//  Created by Kazim Gadjiev on 12.10.2020.
//  Copyright © 2020 Kazim Gajiev. All rights reserved.
//

import UIKit

protocol VideoListPresenterOutput: class {
    
}

protocol VideoListPresenterInput {
    
}

class VideoListPresenter {
    
    // MARK: - Private properties 🕶
    private weak var view: VideoListView!
    private weak var delegate: VideoListPresenterOutput?
    private let photoLibraryManager: PhotoLibraryManagerType = PhotoLibraryManager()
    
    private var videoModels: [VideoModel] = []
    
    // MARK: - Constructor 🏗
    init(view: VideoListView, delegate: VideoListPresenterOutput?) {
        self.view = view
        self.delegate = delegate
    }
    
    // MARK: - View actions
    func loadVideos() {
        photoLibraryManager.fetchVideoFromLibrary { [weak self] (result) in
            self?.videoModels = result
            self?.view.loadVideosCompleted()
        } onError: { [weak self] (error) in
            self?.view.loadVideosError(error)
        }

    }
    
    func getVideosCount() -> Int {
        return videoModels.count
    }
    
    func getVideo(at index: Int) -> VideoModel {
        return videoModels[index]
    }
    
    // MARK: - Input methods
    
    
    // MARK: - Output methods
    
    
}

// MARK: - Input methods
extension VideoListPresenter: VideoListPresenterInput {
    
}

