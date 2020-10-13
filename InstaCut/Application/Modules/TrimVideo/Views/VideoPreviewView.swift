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
    
    private var buttonShowing = true {
        didSet {
            buttonShowing ? showButton() : hideButton()
        }
    }
    
    private var hideButtonTimer: Timer!
    
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
        config()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        config()
        setupUI()
    }
    
    // MARK: - Actions ⚡️
    @objc
    private func actionToggleVideoState(_ sender: UIButton) {
        isPlaying.toggle()
    }
}

// MARK: - Private methods 🕶
fileprivate extension VideoPreviewView {
    
    func config() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
    }
    
    func setupUI() {
        addSubview(playButton)
        
        NSLayoutConstraint.activate([
            playButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            playButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            playButton.widthAnchor.constraint(equalToConstant: 50),
            playButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc func handleTap(_ tapGesture: UITapGestureRecognizer) {
        if isPlaying {
            buttonShowing.toggle()
        }
    }
    
    func toggleVideoState() {
        let imageName = isPlaying ? "media-pause" : "play-button"
        playButton.setImage(UIImage(named: imageName), for: .normal)
        
        if isPlaying {
            videoPlayer.play()
            setupTimer()
        } else {
            invalidateTimer()
            videoPlayer.pause()
        }
    }
    
    func setupTimer() {
        hideButtonTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: { (_) in
            self.buttonShowing.toggle()
        })
    }
    
    func invalidateTimer() {
        self.hideButtonTimer.invalidate()
        self.hideButtonTimer = nil
    }
    
    func hideButton() {
        UIView.animate(withDuration: 0.3) {
            self.playButton.alpha = 0
        } completion: { (_) in
            self.invalidateTimer()
        }
    }
    
    func showButton() {
        UIView.animate(withDuration: 0.3) {
            self.playButton.alpha = 1
        } completion: { (_) in
            if self.hideButtonTimer != nil {
                self.invalidateTimer()
            }
            self.setupTimer()
        }
    }
}

// MARK: - Visible methods 👓
extension VideoPreviewView {
    
    public func attach(videoPlayer: VideoPlayer) {
        self.videoPlayer = videoPlayer
    }
    
}
