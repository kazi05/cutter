//
//  VideoEditorTimeLineState.swift
//  Cutter
//
//  Created by Гаджиев Казим on 18.02.2024.
//

import SwiftUI
import AVFoundation.AVAsset
import Combine

final class VideoEditorTimeLineState: ObservableObject {
    @Published private(set) var timeLineGenerator: VideoTimeLineGenerator!
    @Published var time: CMTime = .zero

    let onPlay = PassthroughSubject<Void, Never>()
    let onPause = PassthroughSubject<Void, Never>()
    let onSeek = PassthroughSubject<CMTime, Never>()

    var subscriptions = Set<AnyCancellable>()

    init(asset: AVAsset) {
        self.timeLineGenerator = .init(asset: asset)
    }

    deinit {
        subscriptions.forEach { $0.cancel() }
        subscriptions.removeAll()
    }

    func play() {
        onPlay.send()
    }

    func pause() {
        onPause.send()
    }

    func seek(to time: CMTime) {
        onSeek.send(time)
    }
}
