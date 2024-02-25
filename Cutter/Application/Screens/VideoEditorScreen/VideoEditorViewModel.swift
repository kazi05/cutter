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
    private weak var initialAsset: AVAsset!
    private var player: VideoPreviewPlayer!

    @Published private(set) var previewState: VideoEditorPreviewState!
    @Published private(set) var editorState: VideoEditorState!

    private var subscriptions = Set<AnyCancellable>()
    private let fileManager = VideoOutputFileManager.shared
    private let videoRenderingStateManager: VideoRenderingStateManager

    init(video: VideoThumbnail, videoRenderingStateManager: VideoRenderingStateManager) {
        self.videoRenderingStateManager = videoRenderingStateManager
        config(with: video)
    }

    deinit {
        print("Deinit view model")
        subscriptions.forEach { $0.cancel() }
        subscriptions.removeAll()
        fileManager.deleteFiles()
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
            print(asset)
            self.initialAsset = asset
            self.configItems(asset)
        }
    }

    func configItems(_ asset: AVAsset) {
        DispatchQueue.main.async { [weak self] in
            self?.subscriptions.forEach { $0.cancel() }
            self?.subscriptions.removeAll()
            self?.player = nil
            self?.previewState = nil
            self?.editorState = nil
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

    func bind() {
        player.$state.sink { [unowned self] state in
            previewState.playerState = state
            editorState.isVideoPlaying = state == .play
        }.store(in: &player.subscriptions)

        player.$time.sink { [unowned self] time in
            editorState.seek(to: time)
        }.store(in: &player.subscriptions)

        editorState.onItemInteracted.sink { [unowned self] item in
            switch item {
            case .playPause:
                player.togglePlaying()
            case .enableDisable:
                previewState.setEraseBackgroundEnabled(!editorState.isEraseEnabled)
            }
        }.store(in: &editorState.subscriptions)

        editorState.optionChangeAccepted.sink { [unowned self] option in
            switch option {
            case .eraseBackground:
                if editorState.isEraseEnabled {
                    Task.do {
                        defer { self.videoRenderingStateManager.completeRenderProgress() }
                        let progress = VideoRenderProgressState(title: "RENDER_ERASE_PROGRESS_TITLE")
                        self.videoRenderingStateManager.beginRenderProgress(progress)
                        guard let url = self.fileManager.generateTemporaryURL(),
                              let asset = try await self.previewState.processVideoFrames(to: url, progress: progress)
                        else {
                            return
                        }
                        self.configItems(asset)
                    } catch: { error in
                        print(error.localizedDescription)
                        self.configItems(self.initialAsset)
                        self.videoRenderingStateManager.completeRenderProgress()
                    }
                } else {
                    configItems(initialAsset)
                }
            default:
                break
            }
        }.store(in: &editorState.subscriptions)

        editorState.onPlay.sink { [unowned self] in
            player.play()
        }.store(in: &editorState.subscriptions)

        editorState.onPause.sink { [unowned self] in
            player.pause()
        }.store(in: &editorState.subscriptions)

        editorState.onSeek.sink { [unowned self] time in
            player.seek(to: time)
            previewState.seekedTime = time
        }.store(in: &editorState.subscriptions)
    }
}
