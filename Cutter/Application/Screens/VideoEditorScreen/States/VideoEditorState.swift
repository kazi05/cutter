//
//  VideoEditorState.swift
//  Cutter
//
//  Created by Гаджиев Казим on 28.01.2024.
//

import SwiftUI
import Combine

final class VideoEditorState: ObservableObject {
    @Published var isVideoPlaying: Bool = false
    @Published var isEraseEnabled: Bool = false

    @Published private(set) var controlState = VideoEditorControlState()
    @Published private(set) var timeLineState: VideoEditorTimeLineState

    private var subscriptions = Set<AnyCancellable>()

    init(asset: VideoAsset) {
        self.timeLineState = .init(asset: asset)
        bind()
    }
}

fileprivate extension VideoEditorState {
    func bind() {
        Publishers.CombineLatest3(
            controlState.$leftOptions,
            controlState.$rightOptions,
            controlState.$centerItems
        ).sink { [unowned self] _ in
            self.objectWillChange.send()
        }.store(in: &subscriptions)
    }
}
