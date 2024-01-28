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
    
    @Published private(set) var preview: VideoPreviewPlayer
    @Published private(set) var controlState = VideoEditorControlState()
    @Published private(set) var editorState = VideoEditorState()
    
    private var subscriptions = Set<AnyCancellable>()
    
    init(video: VideoModel) {
        self.video = video
        self.preview = .init(asset: video.asset)
        bind()
    }
}

fileprivate extension VideoEditorViewModel {
    func bind() {
        preview.$state.sink { [unowned self] state in
            editorState.isVideoPlaying = state == .play
        }.store(in: &subscriptions)
    }
}
