//
//  VideoEditingModel.swift
//  Cutter
//
//  Created by Гаджиев Казим on 19.02.2024.
//

import AVFoundation

final class VideoEditingModel {
    let asset: AVAsset
    let videoNaturalSize: CGSize
    var renderedAsset: AVAsset?
    var options: VideoEditingOptionsModel

    init(
        asset: AVAsset,
        videoNaturalSize: CGSize,
        renderedAsset: AVAsset? = nil,
        options: VideoEditingOptionsModel
    ) {
        self.asset = asset
        self.videoNaturalSize = videoNaturalSize
        self.renderedAsset = renderedAsset
        self.options = options
    }
}

struct VideoEditingOptionsModel {
    var eraseBackground: Bool
}
