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
    @Published private(set) var sizeWarning: String? = nil

    private let videoNaturalSize: CGSize

    init(
        playerItem: AVPlayerItem,
        renderedPlayerItem: AVPlayerItem?,
        videoNaturalSize: CGSize,
        playerState: VideoPlayerState,
        erasingBackground: Bool
    ) {
        self.renderer = .init(
            playerItem: playerItem, 
            renderedPlayerItem: renderedPlayerItem,
            erasingBackground: erasingBackground,
            device: MTLCreateSystemDefaultDevice()!
        )
        self.videoNaturalSize = videoNaturalSize
        self.playerState = playerState
    }

    func getVideoSize() -> CGSize {
        let normalSize = CGSize(width: abs(videoNaturalSize.width), height: abs(videoNaturalSize.height))
        let needRotate = videoNaturalSize.width < normalSize.width
        sizeWarning = renderer.setupVideoSize(normalSize, isNeedRotate: needRotate)
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
