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
    private var lastSeekTime: CMTime!
    
    init(with asset: AVAsset) {
        let playerItem = AVPlayerItem(asset: asset)
        self.player = AVPlayer(playerItem: playerItem)
        let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        self.player.addPeriodicTimeObserver(forInterval: interval, queue: .main, using: { [weak self] time in
            self?.timeChanged?(time)
        })
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func play() {
        player.play()
        isPlaying = true
        statusChanged?(.play)
    }
    
    func pause() {
        player.pause()
        isPlaying = false
        statusChanged?(.pause)
    }
    
    func seek(to time: CMTime, with pause: Bool = true) {
        if pause {
            player.pause()
            isPlaying = false
            statusChanged?(.pause)
        }
        player.seek(to: time)
        lastSeekTime = time
    }
    
    @objc
    private func playerDidFinishPlaying() {
        isPlaying = false
        statusChanged?(.stop)
        player.seek(to: lastSeekTime)
    }
    
}
