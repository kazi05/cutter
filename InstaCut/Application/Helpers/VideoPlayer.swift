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
    
    init(with asset: AVAsset) {
        let playerItem = AVPlayerItem(asset: asset)
        self.player = AVPlayer(playerItem: playerItem)
        let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        self.player.addPeriodicTimeObserver(forInterval: interval, queue: .main, using: { time in
            self.timeChanged?(time)
        })
    }
    
    func play() {
        player.play()
    }
    
    func pause() {
        player.pause()
    }
    
    func seek(to time: CMTime) {
        player.seek(to: time)
    }
    
}
