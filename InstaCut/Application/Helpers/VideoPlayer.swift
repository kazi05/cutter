//
//  VideoPlayer.swift
//  InstaCut
//
//  Created by Kazim Gadjiev on 13.10.2020.
//  Copyright © 2020 Kazim Gajiev. All rights reserved.
//

import AVFoundation

enum VideoPlayerState {
    case play, pause, stop
}

class VideoPlayer {
    
    let player: AVPlayer
    var timeChanged: ((CMTime) -> Void)?
    var statusChanged: ((VideoPlayerState) -> Void)?
    private(set) var isPlaying = false
    let videoDuration: CMTime
    
    private var lastSeekTime: CMTime!
    private var timeObserver: Any!
    
    init(with asset: AVAsset) {
        let playerItem = AVPlayerItem(asset: asset)
        self.player = AVPlayer(playerItem: playerItem)
        self.videoDuration = playerItem.duration
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func play() {
        player.play()
        isPlaying = true
        statusChanged?(.play)
        
        let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main, using: {
            [weak self] time in
            self?.timeChanged?(time)
        })
    }
    
    func pause() {
        afterPause()
    }
    
    private func afterPause() {
        player.pause()
        isPlaying = false
        statusChanged?(.pause)
        if timeObserver != nil {
            player.removeTimeObserver(timeObserver!)
            timeObserver = nil
        }
    }
    
    func seek(to time: CMTime, with pause: Bool = true) {
        if pause {
            afterPause()
        }
        player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
        lastSeekTime = time
        timeChanged?(time)
    }
    
    @objc
    private func playerDidFinishPlaying() {
        isPlaying = false
        statusChanged?(.stop)
        player.seek(to: lastSeekTime)
    }
    
}
