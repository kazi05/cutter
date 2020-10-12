//
//  AssetImageGenerator.swift
//  InstaCut
//
//  Created by Kazim Gadjiev on 12.10.2020.
//  Copyright © 2020 Kazim Gajiev. All rights reserved.
//

import UIKit.UIImage
import AVFoundation

class AssetImageGenerator {
    
    private let asset: AVAsset
    
    init(asset: AVAsset) {
        self.asset = asset
    }
    
    func generateImage() -> UIImage {
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        imageGenerator.requestedTimeToleranceBefore = .zero
        var actualTime: CMTime = .zero
        do {
            let imageRef = try imageGenerator.copyCGImage(at: .zero, actualTime: &actualTime)
            let image = UIImage(cgImage: imageRef)
            return image
        } catch let error as NSError {
            print("\(error.description). Time: \(actualTime)")
            return UIImage()
        }
    }
    
}
