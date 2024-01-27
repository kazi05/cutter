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
    let videoOutput: AVPlayerItemVideoOutput
    
    private let player: AVPlayer
    
    @Published private(set) var state: VideoPlayerState = .stop
    
    // Инициализация Metal и AVFoundation компонентов
    init(asset: AVAsset) {
        self.asset = asset
        self.playerItem = .init(asset: asset)
        self.player = .init(playerItem: playerItem)
        let pixelBufferAttributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA),
            kCVPixelBufferMetalCompatibilityKey as String: true
        ]
        self.videoOutput = AVPlayerItemVideoOutput(pixelBufferAttributes: pixelBufferAttributes)
        super.init()
        setupVideoOutput()
    }
    
    deinit {
        print("Video preview player deinit")
    }
    
    // Настройка вывода видео
    private func setupVideoOutput() {
        playerItem.add(videoOutput)
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

