//
//  VideoPeriodsTrimmerManager.swift
//  InstaCut
//
//  Created by Kazim Gadjiev on 13.10.2020.
//  Copyright © 2020 Kazim Gajiev. All rights reserved.
//

import CoreMedia.CMTime

class VideoPeriodsTrimmerManager {
    
    let group = DispatchGroup()
    let queue = DispatchQueue(label: "trimmingVideo", qos: .userInitiated, attributes: .concurrent)
    
    func trimVideoPerPeriods(_ video: VideoModel, completion: @escaping ([VideoPeriod]) -> Void) {
        queue.async {
            var periods: [VideoPeriod] = []
            let videoDuration = video.asset.duration.seconds
            
            var timeRanges: [Double] = []
            
            stride(from: 0, to: videoDuration, by: 60).forEach {
                timeRanges.append($0)
            }
            
            guard timeRanges.count > 0 else {
                let timeRange = CMTimeRange(start: .zero, duration: CMTimeMakeWithSeconds(videoDuration, preferredTimescale: 600))
                let previewImage = AssetImageGenerator(asset: video.asset).generateImage()
                completion([VideoPeriod(timeRange: timeRange, previewImage: previewImage)])
                return
            }
            
            if videoDuration - timeRanges.last! > 0 {
                timeRanges.append(videoDuration)
            }
            
            self.uniteByPeriods(timeRanges).forEach {
                let start = CMTimeMakeWithSeconds($0.start, preferredTimescale: 600)
                let end = CMTimeMakeWithSeconds($0.end, preferredTimescale: 600)
                let timeRange = CMTimeRange(start: start, end: end)
                let previewImage = AssetImageGenerator(asset: video.asset).generateImage(from: start)
                periods.append(VideoPeriod(timeRange: timeRange, previewImage: previewImage))
            }
            
            DispatchQueue.main.async {
                completion(periods)
            }
        }
    }
    
    private func uniteByPeriods(_ periods: [Double]) -> [(start: Double, end: Double)] {
        var unite: [(Double, Double)] = []
        
        _ = periods.reduce(0) { (start, end) -> Double in
            unite.append((start, end))
            return end
        }
        
        return Array(unite.dropFirst())
    }
    
}
