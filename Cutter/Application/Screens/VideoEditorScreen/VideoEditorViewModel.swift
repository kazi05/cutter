//
//  VideoEditorViewModel.swift
//  Cutter
//
//  Created by Гаджиев Казим on 01.01.2024.
//

import AVFoundation
import SwiftUI
import Combine
import Photos

final class VideoEditorViewModel: ObservableObject {
    
    @Published private var player: VideoPreviewPlayer!

    @Published private(set) var previewState: VideoEditorPreviewState!
    @Published private(set) var editorState: VideoEditorState!

    private var subscriptions = Set<AnyCancellable>()

    init(video: VideoThumbnail) {
        config(with: video)
    }
}

fileprivate extension VideoEditorViewModel {
    func config(with video: VideoThumbnail) {
        let options = PHVideoRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.version = .current
        let imageManager = PHCachingImageManager()
        imageManager.requestAVAsset(forVideo: video.asset, options: options) { asset, _, _ in
            guard let asset else { return }
            DispatchQueue.main.async { [weak self] in
                let playerItem = AVPlayerItem(asset: asset)
                self?.player = .init(playerItem: playerItem)
                self?.previewState = .init(
                    playerItem: playerItem,
                    asset: asset,
                    playerState: .stop
                )
                self?.editorState = .init(asset: asset)
                self?.bind()
            }
        }
    }

    func bind() {
        player.$state.sink { [unowned self] state in
            previewState.playerState = state
            editorState.isVideoPlaying = state == .play
        }.store(in: &subscriptions)

        player.$time.sink { [unowned self] time in
            editorState.timeLineState.time = time
        }.store(in: &subscriptions)

        editorState.controlState.onItemInteracted.sink { [unowned self] item in
            switch item {
            case .playPause:
                player.togglePlaying()
            case .enableDisable:
                previewState.renderer.setEraseBackgroundEnabled(!editorState.isEraseEnabled)
            }
        }.store(in: &subscriptions)

        editorState.timeLineState.onPlay.sink { [unowned self] in
            player.play()
        }.store(in: &subscriptions)

        editorState.timeLineState.onPause.sink { [unowned self] in
            player.pause()
        }.store(in: &subscriptions)

        editorState.timeLineState.onSeek.sink { [unowned self] time in
            player.seek(to: time)
            previewState.seekedTime = time
        }.store(in: &subscriptions)
    }
}
