//
//  VideoTrimmingRenderManager.swift
//  InstaCut
//
//  Created by Kazim Gadjiev on 15.10.2020.
//  Copyright © 2020 Kazim Gajiev. All rights reserved.
//

import AVFoundation

class VideoTrimmingRenderManager {
    
    private let asset: AVAsset
    private let timing: [CMTimeRange]
    private var operationQueue: OperationQueue!
    private var wasCancelled = false
    
    public var periodProgress: ((Int, Float) -> Void)?
    public var periodRenderCompleted: ((Int) -> Void)?
    public var allPeriodsRenderCompleted: (() -> Void)?
    
    init(with asset: AVAsset, and periods: [CMTimeRange]) {
        self.asset = asset
        self.timing = periods
    }
    
    func beginRendering() {
        configureQueue()
    }
    
    func cancelRendering() {
        wasCancelled = true
        operationQueue.cancelAllOperations()
    }
    
    private func configureQueue() {
        operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1
        
        for (index, range) in timing.enumerated() {
            let uploadOperation = VideoUploadOperation(with: asset, range: range) { [weak self] (progress) in
                self?.periodProgress?(index, progress)
            }
            uploadOperation.completionBlock = { [weak self] in
                guard let self = self, !self.wasCancelled else { return }
                
                print("Complete operation")
                
                if index == self.timing.count - 1 {
                    self.allPeriodsRenderCompleted?()
                } else {
                    self.periodRenderCompleted?(index)
                }
            }
            operationQueue.addOperation(uploadOperation)
        }
    }
}
