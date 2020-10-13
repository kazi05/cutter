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
    
    private lazy var gradientView: GradientView = {
        let view = GradientView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.startColor = .clear
        view.endColor = UIColor.black.withAlphaComponent(0.8)
        return view
    }()
    
    private lazy var currentTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AvenirNext-Regular", size: 14)
        label.textColor = UIColor(named: "textColor")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var durationTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AvenirNext-Regular", size: 14)
        label.textColor = UIColor(named: "textColor")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
        toggleVideoState()
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
        
        addSubview(gradientView)
        gradientView.addSubview(currentTimeLabel)
        gradientView.addSubview(durationTimeLabel)
        
        NSLayoutConstraint.activate([
            playButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            playButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            playButton.widthAnchor.constraint(equalToConstant: 50),
            playButton.heightAnchor.constraint(equalToConstant: 50),
            
            gradientView.leadingAnchor.constraint(equalTo: leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: trailingAnchor),
            gradientView.heightAnchor.constraint(equalToConstant: 60),
            gradientView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            currentTimeLabel.centerYAnchor.constraint(equalTo: gradientView.centerYAnchor),
            currentTimeLabel.leadingAnchor.constraint(equalTo: gradientView.leadingAnchor, constant: 20),
            
            durationTimeLabel.centerYAnchor.constraint(equalTo: gradientView.centerYAnchor),
            durationTimeLabel.trailingAnchor.constraint(equalTo: gradientView.trailingAnchor, constant: -20)
        ])
    }
    
    @objc func handleTap(_ tapGesture: UITapGestureRecognizer) {
        if videoPlayer.isPlaying {
            buttonShowing.toggle()
        }
    }
    
    func toggleVideoState() {
        if !videoPlayer.isPlaying {
            videoPlayer.play()
        } else {
            videoPlayer.pause()
        }
    }
    
    func handleVideoState(state: VideoPlayerState) {
        let imageName = videoPlayer.isPlaying ? "media-pause" : "play-button"
        playButton.setImage(UIImage(named: imageName), for: .normal)
        
        switch state {
        case .pause, .stop:
            invalidateTimer()
            buttonShowing = true
            
        case .play:
            setupTimer()
        }
    }
    
    func setupTimer() {
        hideButtonTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: { (_) in
            self.buttonShowing.toggle()
        })
    }
    
    func invalidateTimer() {
        if self.hideButtonTimer != nil {
            self.hideButtonTimer.invalidate()
            self.hideButtonTimer = nil
        }
    }
    
    func hideButton() {
        UIView.animate(withDuration: 0.3) {
            self.playButton.alpha = 0
            self.gradientView.alpha = 0
        } completion: { (_) in
            self.invalidateTimer()
        }
    }
    
    func showButton() {
        UIView.animate(withDuration: 0.3) {
            self.playButton.alpha = 1
            self.gradientView.alpha = 1
        } completion: { (_) in
            self.invalidateTimer()
            if self.videoPlayer.isPlaying {
                self.setupTimer()
            }
        }
    }
}

// MARK: - Visible methods 👓
extension VideoPreviewView {
    
    public func attach(videoPlayer: VideoPlayer) {
        self.videoPlayer = videoPlayer
        durationTimeLabel.text = videoPlayer.player.currentItem?.duration.positionalTime
        currentTimeLabel.text = CMTime.zero.positionalTime
        
        videoPlayer.timeChanged = { [weak self] time in
            self?.currentTimeLabel.text = time.positionalTime
        }
        
        videoPlayer.statusChanged = { [weak self] state in
            self?.handleVideoState(state: state)
        }
    }
    
}
