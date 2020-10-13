//
//  VideoPreviewView.swift
//  InstaCut
//
//  Created by Kazim Gadjiev on 13.10.2020.
//  Copyright © 2020 Kazim Gajiev. All rights reserved.
//

import UIKit
import AVFoundation.AVPlayer

class VideoPreviewView: UIView {
    
    // MARK: - Private properties 🕶
    private var videoPlayer: VideoPlayer! {
        didSet {
            playerLayer.player = videoPlayer.player
        }
    }
    private var isPlaying: Bool = false {
        didSet {
            toggleVideoState()
        }
    }
    
    // MARK: - UI
    private lazy var playButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "play-button"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(actionToggleVideoState), for: .touchUpInside)
        return button
    }()
    
    // MARK: - LifeCycle 🌎
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configUI()
    }
    
    // MARK: - Actions ⚡️
    @objc
    private func actionToggleVideoState(_ sender: UIButton) {
        isPlaying.toggle()
    }
}

// MARK: - Private methods 🕶
fileprivate extension VideoPreviewView {
    
    private func configUI() {
        addSubview(playButton)
        
        NSLayoutConstraint.activate([
            playButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            playButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            playButton.widthAnchor.constraint(equalToConstant: 50),
            playButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func toggleVideoState() {
        let imageName = isPlaying ? "media-pause" : "play-button"
        playButton.setImage(UIImage(named: imageName), for: .normal)
        
        isPlaying ? videoPlayer.play() : videoPlayer.pause()
    }
}

// MARK: - Visible methods 👓
extension VideoPreviewView {
    
    public func attach(videoPlayer: VideoPlayer) {
        self.videoPlayer = videoPlayer
    }
    
}
