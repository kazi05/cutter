//
//  DelegatingVideoHelper.swift
//  InstaCut
//
//  Created by Kazim Gajiev on 06/03/2019.
//  Copyright © 2019 Kazim Gajiev. All rights reserved.
//

import Foundation
import Photos

protocol DelegatingVideoHelperProtocol: class {
    func cutPeriodsFromVideo(_ video: VideoModel) -> [VideoPeriods]
}

class DelegatingVideoHelper: DelegatingVideoHelperProtocol {
    
    func cutPeriodsFromVideo(_ video: VideoModel) -> [VideoPeriods] {
        var periods = [VideoPeriods]()
        let asset = AVAsset(url: video.videoURL)
        let length = asset.duration.seconds
        let rounded: Double = length.rounded()
        var loop = 1
        var start: Double = 0
        var end: Double = 0
        let time = 60
        for index in 1...Int(rounded) {
            if index % (time * loop) == 0  {
                if index == time {
                    start = 0
                    end = Double(time * loop)
                }else {
                    start = Double(time * (loop - 1))
                    end = Double(time * (loop))
                }
                loop += 1
                if let image = thumbnailImage(asset: asset, start: start) {
                    let period = VideoPeriods(start: start, end: end, image: image)
                    periods.append(period)
                }
            }
        }
        if Int(rounded) % (time * loop) > 0 {
            start = Double(time * (loop - 1))
            end = rounded
            if let image = thumbnailImage(asset: asset, start: start) {
                let period = VideoPeriods(start: start, end: end, image: image)
                periods.append(period)
            }
        }
        
        return periods
    }
    
    private func thumbnailImage(asset: AVAsset, start: Double) -> UIImage? {
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            let tumbnailCGIImage = try imageGenerator.copyCGImage(at: CMTime(seconds: start, preferredTimescale: 1000), actualTime: nil)
            return UIImage(cgImage: tumbnailCGIImage)
        }catch {
            print(error)
        }
        
        return nil
    }

    
}
