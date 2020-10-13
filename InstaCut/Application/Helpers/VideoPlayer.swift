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
    
    init(with asset: AVAsset, periodChanged: @escaping (CMTime) -> Void) {
        let playerItem = AVPlayerItem(asset: asset)
        self.player = AVPlayer(playerItem: playerItem)
        let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        self.player.addPeriodicTimeObserver(forInterval: interval, queue: .main, using: periodChanged)
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
