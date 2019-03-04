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
}

protocol CutVideoInteractorInput: class {
    func configureVideoModel(_ videoModel: VideoModel)
    func getImageFromVideo()
}

class CutVideoInteractor: CutVideoInteractorInput {
    
    weak var presenter: CutVideoInteractorOutput!
    var video: VideoModel?
    
    func configureVideoModel(_ videoModel: VideoModel) {
        self.video = videoModel
    }
    
    func getImageFromVideo() {
        if let image = video?.originalImage {
            self.presenter.sendImageFromVideo(image)
        }
    }
    
}
