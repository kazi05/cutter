//
//  AssetImageGenerator.swift
//  Cutter
//
//  Created by Гаджиев Казим on 26.12.2023.
//

import UIKit.UIImage
import AVFoundation

final class AssetImageGenerator {
    
    private let asset: AVAsset
    
    init(asset: AVAsset) {
        self.asset = asset
    }
    
    func generateImage(from startTime: CMTime = .zero) -> UIImage {
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        imageGenerator.requestedTimeToleranceBefore = .zero
        imageGenerator.requestedTimeToleranceAfter = .zero
        
        do {
            let imageRef = try imageGenerator.copyCGImage(at: startTime, actualTime: nil)
            let image = UIImage(cgImage: imageRef)
            return image
        } catch let error as NSError {
            return UIImage()
        }
    }
    
}
