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
    
//    private(set) var collectionImage: UIImage = UIImage()
    var originalImage: UIImage
    var duration: TimeInterval
    
    var durationTime: String {
        return String(format: "%02d:%02d",Int((duration / 60)),Int(duration.rounded()) % 60)
    }
    
    let asset: PHAsset
    
    init(asset: PHAsset) {
        self.asset = asset
        self.duration = asset.duration
        self.originalImage = UIImage()
        self.originalImage = getImage() ?? #imageLiteral(resourceName: "Cutter-maska.png")
    }
    
    private func getImage() -> UIImage? {
        var img: UIImage?
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.version = .original
        options.isSynchronous = true
        manager.requestImageData(for: asset, options: options) { data, _, _, _ in
            if let data = data {
                img = UIImage(data: data)
            }
        }
        return img
    }
}
