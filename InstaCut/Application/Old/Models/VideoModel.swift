//
//  VideoModel.swift
//  InstaCut
//
//  Created by Kazim Gajiev on 03/03/2019.
//  Copyright © 2019 Kazim Gajiev. All rights reserved.
//

import UIKit
import Photos

class VideoModel {
    
    var originalImage: UIImage
    var duration: TimeInterval
    var videoURL: URL
    
    var durationTimeString: String {
        return String(format: "%02d:%02d",Int((duration / 60)),Int(duration.rounded()) % 60)
    }
    
    let asset: PHAsset
    
    init(asset: PHAsset, image: UIImage, videoURL: URL) {
        self.asset = asset
        self.duration = asset.duration
        self.originalImage = image
        self.videoURL = videoURL
    }
}
