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
        VStack(spacing: nil) {
//            VideoEditorPreview(preview: viewModel.preview)
            VideoEditorControlContainer(
                preview: viewModel.preview,
                editorState: viewModel.editorState,
                controlState: viewModel.controlState, 
                timeLineGenerator: viewModel.timeLineGenerator
            )
        }
        .ignoresSafeArea(edges: .bottom)
    }
}
