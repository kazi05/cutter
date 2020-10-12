//
//  CutVideoPresenter.swift
//  InstaCut
//
//  Created by Kazim Gajiev on 03/03/2019.
//  Copyright © 2019 Kazim Gajiev. All rights reserved.
//

import UIKit

protocol CutVideoPresenterInput: CutVideoViewControllerOutput, CutVideoInteractorOutput {}

class CutVideoPresenter: CutVideoPresenterInput {
    
    weak var viewController: CutVideoViewControllerInput!
    var interactor: CutVideoInteractorInput!
    
    //MARK:- Passing data from MainScreen module to interactor
    func saveSelectedVideoModel(_ videoModel: VideoModel) {
        self.interactor.configureVideoModel(videoModel)
    }
    
    //MARK:- Call methods coming from view to interactor
    func loadImageFromVideo() {
        self.interactor.getImageFromVideo()
    }
    
    func getPeriodsForVideo() {
        self.interactor.getPeriodsForVideo()
    }
    
    func getVideoURL() {
        self.interactor.getVideoURLFromModel()
    }
    
    func saveVideosToPhotoAlbum(from videoURL: URL, periods: [VideoPeriods], popUpView: PopUpViewController) {
        self.interactor.saveVideosToPhotoAlbum(from: videoURL, periods: periods, popUpView: popUpView)
    }
    
    //MARK:- results comes from Interactor
    func sendImageFromVideo(_ image: UIImage) {
        self.viewController.addPreviewImage(image)
    }
    
    func sendPeriodsFromVideo(_ periods: [VideoPeriods]) {
        self.viewController.applyPeriodsForVideo(periods)
    }
    
    func sendVideoURL(_ videoURL: URL) {
        self.viewController.passVideoURL(videoURL)
    }
    
}
