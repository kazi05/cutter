//
//  VideoEditorScreen.swift
//  Cutter
//
//  Created by Гаджиев Казим on 28.12.2023.
//

import SwiftUI
import AVKit

struct VideoEditorScreen: View {
    @StateObject var viewModel: VideoEditorViewModel
    
    var body: some View {
        if viewModel.previewState != nil && viewModel.editorState != nil {
            VStack(spacing: nil) {
                VideoEditorPreview(preview: viewModel.previewState)
                VideoEditorControlContainer(editorState: viewModel.editorState)
            }
            .ignoresSafeArea(edges: .bottom)
        } else {
            ProgressView()
        }
    }
}
