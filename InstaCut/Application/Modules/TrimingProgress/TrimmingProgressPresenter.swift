//
//  TriminProgressPresenter.swift
//  InstaCut
//
//  Created by Kazim Gadjiev on 14.10.2020.
//  Copyright © 2020 Kazim Gajiev. All rights reserved.
//

import Foundation

protocol TrimmingProgressPresenterOutput: class {
    
}

class TrimmingProgressPresenter {
    
    // MARK: - Private properties 🕶
    private weak var view: TrimmingProgressView!
    private weak var delegate: TrimmingProgressPresenterOutput!
    private var trimmingRenderManager: VideoTrimmingRenderManager!
    private let periods: [VideoPeriod]
    private var completedPeriodsIndexes = Set<Int>()
    
    // MARK: - Constructor 🏗
    init(view: TrimmingProgressView,
         video: VideoModel,
         periods: [VideoPeriod],
         delegate: TrimmingProgressPresenterOutput) {
        self.view = view
        self.periods = periods
        self.delegate = delegate
        self.trimmingRenderManager = VideoTrimmingRenderManager(with: video.asset,
                                                                and: periods.map { $0.timeRange} )
    }
    
    // MARK: - View actions
    func beginRendering() {
        trimmingRenderManager.beginRendering()
        
        trimmingRenderManager.periodProgress = { [weak self] index, progress in
            DispatchQueue.main.async {
                self?.periodAt(index: index, progress: progress)
            }
        }
        
        trimmingRenderManager.periodRenderCompleted = { [weak self] index in
            DispatchQueue.main.async {
                self?.periodCompleted(at: index)
            }
        }
        
        trimmingRenderManager.allPeriodsRenderCompleted = { [weak self] in
            DispatchQueue.main.async {
                self?.renderingCompleted()
            }
        }
    }
    
    func cancelRendering() {
        trimmingRenderManager.cancelRendering()
    }
    
    func getPeriodsCount() -> Int {
        return periods.count
    }
    
    func getPreiod(at index: Int) -> VideoPeriod {
        return periods[index]
    }
    
    func isPeriodCompleted(at index: Int) -> Bool {
        return completedPeriodsIndexes.contains(index)
    }
    
    // MARK: - Input methods
    private func periodAt(index: Int, progress: Float) {
        view.period(at: index, progress: progress)
    }
    
    private func periodCompleted(at index: Int) {
        view.periodCompleted(at: index)
    }
    
    private func renderingCompleted() {
        view.renderingCompleted()
    }
    
    // MARK: - Output methods
    
}
