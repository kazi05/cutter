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
    private var model: VideoEditingModel!
    private var player: VideoPreviewPlayer!

    @Published private(set) var previewState: VideoEditorPreviewState!
    @Published private(set) var editorState: VideoEditorState!
    @Published private(set) var assetUrlForSave: URL? = nil

    private var subscriptions = Set<AnyCancellable>()
    private let fileManager = VideoOutputFileManager.shared
    private let videoRenderingStateManager: VideoRenderingStateManager
    private let adCoordinator = AdCoordinator.shared

    init(video: VideoThumbnail, videoRenderingStateManager: VideoRenderingStateManager) {
        self.videoRenderingStateManager = videoRenderingStateManager
        config(with: video)
    }

    deinit {
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
            Task.detached {
                guard let track = try await asset.loadTracks(withMediaType: .video).first else {
                    return
                }
                let (transform, naturalSize) = try await track.load(.preferredTransform, .naturalSize)
                let size = naturalSize.applying(transform)
                
                self.model = VideoEditingModel(
                    asset: asset,
                    videoNaturalSize: size,
                    options: .init(eraseBackground: false)
                )
                self.configItems()
            }
        }
    }

    func configItems() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            subscriptions.forEach { $0.cancel() }
            subscriptions.removeAll()
            player = nil
            previewState = nil
            editorState = nil
            let asset = model.asset
            let renderedAsset = model.renderedAsset
            let playerItem = AVPlayerItem(asset: asset)
            let renderedPlayerItem: AVPlayerItem? = if let asset = model.renderedAsset {
                AVPlayerItem(asset: asset)
            } else {
                nil
            }
            player = .init(playerItem: playerItem, renderedPlayerItem: renderedPlayerItem)
            previewState = .init(
                playerItem: playerItem,
                renderedPlayerItem: renderedPlayerItem,
                videoNaturalSize: model.videoNaturalSize,
                playerState: .stop,
                erasingBackground: model.options.eraseBackground
            )
            editorState = .init(
                asset: renderedAsset ?? asset,
                isEraseEnabled: self.model.options.eraseBackground
            )
            assetUrlForSave = (model.renderedAsset as? AVURLAsset)?.url
            adCoordinator.loadAd()
            bind()
        }
    }

    func bind() {
        player.$state.receive(on: DispatchQueue.main).sink { [unowned self] state in
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
                    if model.options.eraseBackground {
                        return
                    }
                    Task.do {
                        defer { self.videoRenderingStateManager.completeRenderProgress() }
                        let progress = VideoRenderProgressState(title: "RENDER_ERASE_PROGRESS_TITLE")
                        self.videoRenderingStateManager.beginRenderProgress(progress)
                        guard let url = self.fileManager.generateTemporaryURL(),
                              let asset = try await self.previewState.processVideoFrames(to: url, progress: progress)
                        else {
                            return
                        }
                        self.model.renderedAsset = asset
                        self.model.options.eraseBackground = true
                        self.configItems()
                    } catch: { error in
                        print(error.localizedDescription)
                        self.configItems()
                        self.videoRenderingStateManager.completeRenderProgress()
                    }
                } else {
                    self.model.renderedAsset = nil
                    self.model.options.eraseBackground = false
                    configItems()
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
