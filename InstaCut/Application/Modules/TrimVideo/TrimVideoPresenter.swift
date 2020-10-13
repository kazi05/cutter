//
//  TrimVideoPresenter.swift
//  InstaCut
//
//  Created by Kazim Gadjiev on 12.10.2020.
//  Copyright © 2020 Kazim Gajiev. All rights reserved.
//

import Foundation

class TrimVideoPresenter {
    
    // MARK: - Private properties 🕶
    private weak var view: TrimVideoView!
    private let video: VideoModel
    
    private var periods: [VideoPeriod] = []
    
    // MARK: - Constructor 🏗
    init(view: TrimVideoView, video: VideoModel) {
        self.view = view
        self.video = video
        loadPeriods()
    }
    
    // MARK: - View actions
    func attachPlayer() {
        view.showVideo(video)
    }
    private func loadPeriods() {
        periods = []
        VideoPeriodsTrimmerManager().trimVideoPerPeriods(video) { [weak self] result in
            self?.periods = result
            self?.view.periodsCreated()
        }
    }
    
    func getPeriodsCount() -> Int {
        return periods.count
    }
    
    func getPreiod(at index: Int) -> VideoPeriod {
        return periods[index]
    }
    
    // MARK: - Input methods
    
    
    // MARK: - Output methods
    
}
