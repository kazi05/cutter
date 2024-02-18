//
//  VidePlayer.swift
//  Cutter
//
//  Created by Гаджиев Казим on 01.01.2024.
//

import AVFoundation
import SwiftUI
import Combine

enum VideoPlayerState {
    case play, pause, stop
}

final class VideoPreviewPlayer: NSObject, ObservableObject {
    
    private let player: AVPlayer
    private var timeObserver: Any?
    private var subscriptions = Set<AnyCancellable>()
    
    @Published private(set) var state: VideoPlayerState = .stop
    @Published private(set) var time: CMTime = .zero
    
    init(playerItem: AVPlayerItem) {
        self.player = .init(playerItem: playerItem)
        super.init()
        
        NotificationCenter.default.publisher(for: AVPlayerItem.didPlayToEndTimeNotification)
            .sink { [unowned self]_ in
                playerDidFinishPlaying()
            }
            .store(in: &subscriptions)
    }
    
    deinit {
        if timeObserver != nil {
            player.removeTimeObserver(timeObserver!)
            timeObserver = nil
        }
    }
    
    func togglePlaying() {
        switch state {
        case .play:
            pause()
        case .pause, .stop:
            play()
        }
    }
    
    // Воспроизведение видео
    func play() {
        state = .play
        player.play()
        
        let interval = CMTime(seconds: 0.01, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main, using: {
            [weak self] time in
            self?.time = time
        })
    }
    
    // Пауза
    func pause() {
        afterPause()
    }
    
    func seek(to time: CMTime) {
        player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
        self.time = time
    }
}

fileprivate extension VideoPreviewPlayer {
    func afterPause() {
        state = .pause
        player.pause()
        if timeObserver != nil {
            player.removeTimeObserver(timeObserver!)
            timeObserver = nil
        }
    }
    
    func playerDidFinishPlaying() {
        state = .stop
        player.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero)
        time = .zero
    }
}
