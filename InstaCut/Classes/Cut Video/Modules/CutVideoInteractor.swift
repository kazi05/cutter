//
//  CutVideoInteractor.swift
//  InstaCut
//
//  Created by Kazim Gajiev on 03/03/2019.
//  Copyright © 2019 Kazim Gajiev. All rights reserved.
//

import UIKit

protocol CutVideoInteractorOutput: class {
    func sendImageFromVideo(_ image: UIImage)
    func sendPeriodsFromVideo(_ periods: [VideoPeriods])
    func sendVideoURL(_ videoURL: URL)
}

protocol CutVideoInteractorInput: class {
    func configureVideoModel(_ videoModel: VideoModel)
    func getImageFromVideo()
    func getPeriodsForVideo()
    func getVideoURLFromModel()
}

class CutVideoInteractor: CutVideoInteractorInput {
    
    weak var presenter: CutVideoInteractorOutput!
    var video: VideoModel?
    var delegateVideoManager: DelegatingVideoHelperProtocol!
    
    func configureVideoModel(_ videoModel: VideoModel) {
        self.video = videoModel
    }
    
    func getImageFromVideo() {
        if let image = video?.originalImage {
            self.presenter.sendImageFromVideo(image)
        }
    }
    
    func getPeriodsForVideo() {
        if let videoAsset = video {
            let periods = delegateVideoManager.cutPeriodsFromVideo(videoAsset)
            self.presenter.sendPeriodsFromVideo(periods)
        }
    }
    
    func getVideoURLFromModel() {
        if let videoURL = video?.videoURL {
            self.presenter.sendVideoURL(videoURL)
        }
    }
        
}
