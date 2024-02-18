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
        self.renderer = .init(playerItem: playerItem)
        self.asset = asset
        self.playerState = playerState
    }

    func getVideoSize() async throws -> CGSize {
        try await asset.videoSize() ?? .zero
    }
}
