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
}

protocol CutVideoInteractorInput: class {
    func configureVideoModel(_ videoModel: VideoModel)
    func getImageFromVideo()
    func getPeriodsForVideo()
}

class CutVideoInteractor: CutVideoInteractorInput {
    
    weak var presenter: CutVideoInteractorOutput!
    var video: VideoModel?
    var delegatingVideoHelperProtocol: DelegatingVideoHelperProtocol!
    
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
            let periods = delegatingVideoHelperProtocol.cutPeriodsFromVideo(videoAsset)
            print(periods.map { $0.start })
            print(periods.map { $0.end })
        }
    }
        
}
