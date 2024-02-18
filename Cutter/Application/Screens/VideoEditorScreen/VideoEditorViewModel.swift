//
//  VideoEditorViewModel.swift
//  Cutter
//
//  Created by Гаджиев Казим on 01.01.2024.
//

import AVFoundation
import SwiftUI
import Combine

final class VideoEditorViewModel: ObservableObject {
    let video: VideoModel
    
    @Published private var preview: VideoPreviewPlayer

    @Published private(set) var previewState: VideoEditorPreviewState
    @Published private(set) var editorState: VideoEditorState

    private var subscriptions = Set<AnyCancellable>()
    
    init(video: VideoModel) {
        self.video = video
        let playerItem = AVPlayerItem(asset: video.asset)
        self.preview = .init(playerItem: playerItem)
        self.previewState = .init(
            playerItem: playerItem,
            asset: video.asset,
            playerState: .stop
        )
        self.editorState = .init(asset: video.asset)
        bind()
    }
}

fileprivate extension VideoEditorViewModel {
    func bind() {
        preview.$state.sink { [unowned self] state in
            previewState.playerState = state
            editorState.isVideoPlaying = state == .play
        }.store(in: &subscriptions)

        preview.$time.sink { [unowned self] time in
            editorState.timeLineState.time = time
        }.store(in: &subscriptions)

        editorState.controlState.onItemInteracted.sink { [unowned self] item in
            switch item {
            case .playPause:
                preview.togglePlaying()
            case .enableDisable:
                break
            }
        }.store(in: &subscriptions)

        editorState.timeLineState.onPlay.sink { [unowned self] in
            preview.play()
        }.store(in: &subscriptions)

        editorState.timeLineState.onPause.sink { [unowned self] in
            preview.pause()
        }.store(in: &subscriptions)

        editorState.timeLineState.onSeek.sink { [unowned self] time in
            preview.seek(to: time)
            previewState.seekedTime = time
        }.store(in: &subscriptions)
    }
}
