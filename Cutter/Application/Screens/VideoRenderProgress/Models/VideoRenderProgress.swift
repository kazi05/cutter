//
//  VideoRenderProgress.swift
//  Cutter
//
//  Created by Гаджиев Казим on 25.02.2024.
//

import AVFoundation

final class VideoRenderProgressState: ObservableObject {
    let title: String

    @Published private(set) var progress: CGFloat
    private(set) var cancelRendering: (() -> Void)?

    init(title: String, progress: CGFloat = 0.0) {
        self.title = title
        self.progress = progress
    }

    func updateProgress(_ value: CGFloat) {
        DispatchQueue.main.async {
            self.progress = value
        }
    }

    func handleCancel(_ handler: @escaping (() -> Void)) {
        cancelRendering = handler
    }
}
