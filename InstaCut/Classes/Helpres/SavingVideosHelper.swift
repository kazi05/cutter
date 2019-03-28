//
//  SavingVideosHelper.swift
//  InstaCut
//
//  Created by Kazim Gajiev on 28/03/2019.
//  Copyright © 2019 Kazim Gajiev. All rights reserved.
//

import Foundation

protocol SavingVideosHelperProtocol: class {
    func saveVideos(from videoURL: URL, with periods: [VideoPeriods])
}

class SavingVideosHelper: SavingVideosHelperProtocol, IterationObserver {
    
    private let observerCenter = ObserverCenters()

    init(popUpView: PopUpViewController) {
        observerCenter.subscribe(self)
        observerCenter.subscribe(popUpView)
    }

    func saveVideos(from videoURL: URL, with periods: [VideoPeriods]) {
        let dispatchGroup = DispatchQueue.global()

        dispatchGroup.async {
            DispatchQueue.concurrentPerform(iterations: periods.count, execute: { (id: Int) in
                sleep(UInt32(id + 1))
                self.observerCenter.notify(index: id)
            })
        }
    }
    
}
