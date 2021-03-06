//
//  TrimVideoPresenter.swift
//  InstaCut
//
//  Created by Kazim Gadjiev on 12.10.2020.
//  Copyright © 2020 Kazim Gajiev. All rights reserved.
//

import UIKit
import AVFoundation

protocol TrimVideoPresenterOutput: class {
    func saveVideos(from video: VideoModel, with periods: [VideoPeriod], and settings: VideoRenderSettings)
    
    func purchaseNoMask(product: IAPProduct, period: VideoPeriod)
    
    func purchaseProgressBar(product: IAPProduct, period: VideoPeriod)
    
    func showColorPickerController(color: UIColor?) -> ProgressColorPickerController
}

protocol TrimVideoPresenterInput: class {
    func purchaseCompleted(_ product: IAPProduct)
    
    func progressColorChanged(_ color: UIColor)
    
    func progressColorChoosed(_ color: UIColor)
    
    func progressColorRemoved()
    
    func progressColorCanceled()
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
            currentPeriod = periods.first
        }
    }
    private var periodsRanges: [CMTimeRange] = []
    private var previousRangeIndex = 0
    private var currentPeriod: VideoPeriod!
    
    private var renderSettings = VideoRenderSettings()
    
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
        currentPeriod = periods[index]
        let start = periods[index].timeRange.start
        videoPlayer.seek(to: start)
    }
    
    func destroyPlayerNow() {
        videoPlayer.pause()
        videoPlayer = nil
    }
    
    func saveVideos() {
        guard let urlAsset = video.asset as? AVURLAsset else { return }
        guard let fileSize = urlAsset.fileSize, DiskStatus.freeDiskSpaceInBytes > fileSize else {
            view.memoryIsFullError()
            return
        }
        delegate.saveVideos(from: video, with: periods, and: renderSettings)
    }
    
    func showProgressBar() -> ProgressColorPickerController? {
        videoPlayer.pause()
        if IAPManager.shared.purchasedProducts.contains(.progress) {
            return delegate.showColorPickerController(color: renderSettings.progressSettings?.color)
        } else if let product = IAPManager.shared.getProduct(by: .progress) {
            delegate.purchaseProgressBar(product: product, period: currentPeriod)
            return nil
        } else {
            return nil
        }
    }
    
    // MARK: - Private methods
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
        currentPeriod = periods[index]
        view.periodChanged(index)
    }
    
    func purchaseNoMask() {
        if let product = IAPManager.shared.getProduct(by: .mask) {
            videoPlayer.pause()
            delegate.purchaseNoMask(product: product, period: currentPeriod)
        }
    }
    
}

// MARK: - Input methods
extension TrimVideoPresenter: TrimVideoPresenterInput {
    
    func purchaseCompleted(_ product: IAPProduct) {
        switch product.kind {
        case .mask:
            view.hideNoMaskButton()
            
        case .progress:
            view.progressBarPurchased(delegate.showColorPickerController(color: nil))
            if IAPManager.shared.purchasedProducts.contains(.mask) {
                view.hideNoMaskButton()
            }
        }
    }
    
    func progressColorChanged(_ color: UIColor) {
        view.progressColorChanged(color)
    }
    
    func progressColorChoosed(_ color: UIColor) {
        renderSettings.progressSettings = VideoProgressSettings(color: color)
        view.progressColorChoosed(color)
    }
    
    func progressColorRemoved() {
        renderSettings.progressSettings = nil
        view.progressColorRemoved()
    }
    
    func progressColorCanceled() {
        view.progressColorCanceled()
    }
}
