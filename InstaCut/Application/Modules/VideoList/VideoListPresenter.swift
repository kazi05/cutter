//
//  VideoListPresenter.swift
//  InstaCut
//
//  Created by Kazim Gadjiev on 12.10.2020.
//  Copyright © 2020 Kazim Gajiev. All rights reserved.
//

import UIKit

protocol VideoListPresenterOutput: class {
    func showVideoTrimmer(by asset: VideoModel)
}

protocol VideoListPresenterInput {
    
}

class VideoListPresenter {
    
    // MARK: - Private properties 🕶
    private weak var view: VideoListView!
    private weak var delegate: VideoListPresenterOutput?
    
    private var videoModels: [VideoModel] = []
    
    // MARK: - Constructor 🏗
    init(view: VideoListView, delegate: VideoListPresenterOutput?) {
        self.view = view
        self.delegate = delegate
    }
    
    // MARK: - View actions
    func loadVideos() {
        PhotoLibraryManager().fetchVideoFromLibrary { [weak self] (result) in
            switch result {
            case .failure(let error):
                self?.view.loadVideosError(error)
                
            case .success(let videos):
                self?.videoModels = videos
                self?.view.loadVideosCompleted()

            }
            
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
    func presentTrimmerView(by index: Int) {
        let video = videoModels[index]
        delegate?.showVideoTrimmer(by: video)
    }
    
}

// MARK: - Input methods
extension VideoListPresenter: VideoListPresenterInput {
    
}

