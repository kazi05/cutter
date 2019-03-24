//
//  VideoPlayerView.swift
//  InstaCut
//
//  Created by Kazim Gajiev on 24/03/2019.
//  Copyright © 2019 Kazim Gajiev. All rights reserved.
//

import UIKit
import AVFoundation

class VideoPlayerView: UIView {
    
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    var player: AVPlayer? {
        get {
            return playerLayer.player
        }
        set {
            playerLayer.player = newValue
        }
    }
    
    private var previewImage: UIImageView?
    
    init() {
        super.init(frame: .zero)
    }
    
    init(viedoURL: URL, previewImage: UIImageView) {
        super.init(frame: .zero)
        self.player = AVPlayer(url: viedoURL)
        self.previewImage = previewImage
    }
    
    private func getFrameOfPreview() -> CGRect {
        return previewImage!.calculateRectOfImageInImageView()
    }
    
    override func layoutSubviews() {
        playerLayer.frame = getFrameOfPreview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}