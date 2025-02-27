//
//  ContentDetailsScreen.swift
//  Cutter
//
//  Created by Гаджиев Казим on 28.12.2023.
//

import SwiftUI

struct ContentDetailsScreen: View {
    @EnvironmentObject private var navigationStateManager: AppNavigationStateManager
    private let videoRenderingStateManager: VideoRenderingStateManager

    init(videoRenderingStateManager: VideoRenderingStateManager) {
        self.videoRenderingStateManager = videoRenderingStateManager
    }

    var body: some View {
        if let state = navigationStateManager.selectionState {
            switch state {
            case .videoEditing(let videoModel):
                let viewModel = VideoEditorViewModel(
                    video: videoModel,
                    videoRenderingStateManager: videoRenderingStateManager
                )
                VideoEditorScreen(viewModel: viewModel)
                    .id(videoModel.id)
            }
        } else {
            Text("DETAILS_PICK_VIDEO")
        }
    }
}
