//
//  VideoEditorState.swift
//  Cutter
//
//  Created by Гаджиев Казим on 28.01.2024.
//

import SwiftUI
import Combine
import AVFoundation.AVAsset

final class VideoEditorState: ObservableObject {
    @Published var isVideoPlaying: Bool = false
    @Published var isEraseEnabled: Bool = false

    @Published private(set) var controlState = VideoEditorControlState()
    @Published private(set) var timeLineState: VideoEditorTimeLineState

    let optionChangeAccepted = PassthroughSubject<VideoEditorControlItem.Option, Never>()
    let onItemInteracted = PassthroughSubject<VideoEditorControlItem.Interaction, Never>()

    let onPlay = PassthroughSubject<Void, Never>()
    let onPause = PassthroughSubject<Void, Never>()
    let onSeek = PassthroughSubject<CMTime, Never>()

    var subscriptions = Set<AnyCancellable>()

    init(asset: AVAsset) {
        self.timeLineState = .init(asset: asset)
        bind()
    }

    deinit {
        print("Deinit editor state")
        subscriptions.forEach { $0.cancel() }
        subscriptions.removeAll()
    }

    public func seek(to time: CMTime) {
        timeLineState.time = time
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

        controlState.optionChangeAccepted.sink { [unowned self] option in
            optionChangeAccepted.send(option)
        }.store(in: &subscriptions)

        controlState.onItemInteracted.sink { [unowned self] item in
            onItemInteracted.send(item)
        }.store(in: &subscriptions)

        $isEraseEnabled.sink { [unowned self] enabled in
            controlState.onItemInteracted.send(.enableDisable)
        }.store(in: &subscriptions)

        timeLineState.onPlay.sink { [unowned self] in
            onPlay.send()
        }.store(in: &subscriptions)

        timeLineState.onPause.sink { [unowned self] in
            onPause.send()
        }.store(in: &subscriptions)

        timeLineState.onSeek.sink { [unowned self] time in
            onSeek.send(time)
        }.store(in: &subscriptions)
    }
}
