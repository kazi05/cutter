//
//  TrimVideoPresenter.swift
//  InstaCut
//
//  Created by Kazim Gadjiev on 12.10.2020.
//  Copyright © 2020 Kazim Gajiev. All rights reserved.
//

import Foundation
import CoreMedia.CMTime

protocol TrimVideoPresenterOutput: class {
    func saveVideos(with periods: [VideoPeriod])
}

class TrimVideoPresenter {
    
    // MARK: - Private properties 🕶
    private weak var view: TrimVideoView!
    private weak var delegate: TrimVideoPresenterOutput!
    private let video: VideoModel
    private var videoPlayer: VideoPlayer!
    private var periods: [VideoPeriod] = [] {
        didSet {
            periodsRanges = periods.map { $0.timeRange }
        }
    }
    private var periodsRanges: [CMTimeRange] = []
    private var previousRangeIndex = 0
    
    // MARK: - Constructor 🏗
    init(view: TrimVideoView, delegate: TrimVideoPresenterOutput, video: VideoModel) {
        self.view = view
        self.delegate = delegate
        self.video = video
        loadPeriods()
    }
    
    // MARK: - View actions
    func attachPlayer() {
        videoPlayer = VideoPlayer(with: video.asset)
        videoPlayer.timeChanged = { [weak self] time in
            self?.observePlayerTime(time)
        }
        view.showVideo(videoPlayer)
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
    
    func seekVideo(at index: Int) {
        let start = periods[index].timeRange.start
        videoPlayer.seek(to: start)
    }
    
    func destroyPlayerNow() {
        videoPlayer.pause()
        videoPlayer = nil
    }
    
    func saveVideos() {
        delegate.saveVideos(with: periods)
    }
    
    // MARK: - Input methods
    private func observePlayerTime(_ time: CMTime) {
        view.playerTimeDidChange(time)
        if let index = self.periodsRanges.firstIndex(where: { $0.containsTime(time) }),
           index != self.previousRangeIndex {
            self.previousRangeIndex = index
            self.periodChanged(to: index)
        }
    }
    
    // MARK: - Output methods
    private func periodChanged(to index: Int) {
        view.periodChanged(index)
    }
    
}
