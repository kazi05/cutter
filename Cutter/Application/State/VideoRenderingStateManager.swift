//
//  VideoRenderingStateManager.swift
//  Cutter
//
//  Created by Гаджиев Казим on 25.02.2024.
//

import SwiftUI

final class VideoRenderingStateManager: ObservableObject {
    @Published private(set) var progressModel: VideoRenderProgressState? = nil

    func beginRenderProgress(_ model: VideoRenderProgressState) {
        progressModel = model
    }

    func completeRenderProgress() {
        DispatchQueue.main.async {
            self.progressModel = nil
        }
    }
}
