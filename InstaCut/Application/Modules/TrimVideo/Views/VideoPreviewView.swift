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
            if videoPlayer != nil {
                playerLayer.player = videoPlayer.player
            }
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
        view.endColor = UIColor.black.withAlphaComponent(0.6)
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
    
    private let progressWide: CGFloat = 10
    
    private lazy var progressLayer: CAShapeLayer = {
        let progressLayer = CAShapeLayer()
        progressLayer.fillColor = nil
        progressLayer.strokeColor = UIColor(named: "appMainColor")?.cgColor
        progressLayer.lineWidth = progressWide
        return progressLayer
    }()
    
    // Key-value observing context
    private var playerItemContext = 0
    
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
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {

        // Only handle observations for the playerItemContext
        guard context == &playerItemContext else {
            super.observeValue(forKeyPath: keyPath,
                               of: object,
                               change: change,
                               context: context)
            return
        }

        if keyPath == #keyPath(AVPlayerItem.status) {
            let status: AVPlayerItem.Status
            if let statusNumber = change?[.newKey] as? NSNumber {
                status = AVPlayerItem.Status(rawValue: statusNumber.intValue)!
            } else {
                status = .unknown
            }

            // Switch over status value
            switch status {
            case .readyToPlay:
                let rect = playerLayer.videoRect
                let path = UIBezierPath()
                path.move(to: CGPoint(x: 0, y: rect.maxY - progressWide / 2))
                path.addLine(to: CGPoint(x: bounds.width, y: rect.maxY - progressWide / 2))
                progressLayer.path = path.cgPath
                
            default: break
                // Player item is not yet ready.
            }
        }
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
        self.videoPlayer.player.currentItem!.addObserver(self,
                                                         forKeyPath: #keyPath(AVPlayerItem.status),
                                                         options: [.old, .new],
                                                         context: &playerItemContext)
        durationTimeLabel.text = videoPlayer.player.currentItem?.duration.positionalTime
        currentTimeLabel.text = CMTime.zero.positionalTime
        
        videoPlayer.statusChanged = { [weak self] state in
            self?.handleVideoState(state: state)
        }
    }
    
    public func playerTimeDidChange(time: CMTime) {
        currentTimeLabel.text = time.positionalTime
    }
    
    public func showProgressDemostration(_ show: Bool) {
        gradientView.alpha = show ? 0 : 1
        playButton.alpha = show ? 0 : 1
        
        if show {
            layer.addSublayer(progressLayer)
            progressLayer.addProgressAnimation(repeated: true)
        } else {
            progressLayer.removeFromSuperlayer()
            progressLayer.removeAllAnimations()
        }
    }
    
    public func setProgressColor(color: UIColor) {
        progressLayer.strokeColor = color.cgColor
    }
    
}
