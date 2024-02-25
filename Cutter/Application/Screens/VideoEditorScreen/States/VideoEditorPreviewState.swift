//
//  VideoEditorPreviewState.swift
//  Cutter
//
//  Created by Гаджиев Казим on 18.02.2024.
//

import SwiftUI
import AVFoundation

final class VideoEditorPreviewState: ObservableObject {

    let renderer: VideoPreviewRenderer
    @Published var playerState: VideoPlayerState
    @Published var seekedTime: CMTime = .zero

    private let asset: AVAsset

    init(
        playerItem: AVPlayerItem,
        asset: AVAsset,
        playerState: VideoPlayerState
    ) {
        self.renderer = .init(playerItem: playerItem, device: MTLCreateSystemDefaultDevice()!)
        self.asset = asset
        self.playerState = playerState
    }

    deinit {
        print("Deinit preview state")
    }

    func getVideoSize() async throws -> CGSize {
        guard let track = try await asset.loadTracks(withMediaType: .video).first else {
            return .zero
        }
        let transform = try await track.load(.preferredTransform)
        let size = try await track.load(.naturalSize).applying(transform)
        let normalSize = CGSize(width: abs(size.width), height: abs(size.height))
        let needRotate = size.width < normalSize.width
        renderer.setupVideoSize(normalSize, isNeedRotate: needRotate)
        return normalSize
    }

    func setEraseBackgroundEnabled(_ enabled: Bool) {
        renderer.setEraseBackgroundEnabled(enabled)
    }

    func processVideoFrames(
        to destinationURL: URL,
        progress: VideoRenderProgressState
    ) async throws -> AVAsset? {
        try await renderer.processVideoFrames(to: destinationURL, progress: progress)
    }
}
