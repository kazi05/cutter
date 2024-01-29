//
//  VidePlayer.swift
//  Cutter
//
//  Created by Гаджиев Казим on 01.01.2024.
//

import AVFoundation
import SwiftUI

enum VideoPlayerState {
    case play, pause, stop
}

final class VideoPreviewPlayer: NSObject, ObservableObject {
    
    let asset: AVAsset
    let playerItem: AVPlayerItem
    
    private let player: AVPlayer
    
    @Published private(set) var state: VideoPlayerState = .stop
    
    // Инициализация Metal и AVFoundation компонентов
    init(asset: AVAsset) {
        self.asset = asset
        self.playerItem = .init(asset: asset)
        self.player = .init(playerItem: playerItem)
        super.init()
    }
    
    deinit {
        print("Video preview player deinit")
    }
    
    func togglePlaying() {
        switch state {
        case .play:
            state = .pause
            player.pause()
        case .pause, .stop:
            state = .play
            player.play()
        }
    }
    
    // Воспроизведение видео
    func play() {
        state = .play
        player.play()
    }
    
    // Пауза
    func pause() {
        state = .pause
        player.pause()
    }
}

