//
//  VideoEditorControlContainer.swift
//  Cutter
//
//  Created by Гаджиев Казим on 25.01.2024.
//

import SwiftUI

struct VideoEditorControlContainer: View {
    @ObservedObject private var preview: VideoPreviewPlayer
    @ObservedObject private var editorState: VideoEditorState
    @ObservedObject private var controlState: VideoEditorControlState
    @ObservedObject private var timeLineGenerator: VideoTimeLineGenerator
    
    init(
        preview: VideoPreviewPlayer,
        editorState: VideoEditorState,
        controlState: VideoEditorControlState,
        timeLineGenerator: VideoTimeLineGenerator
    ) {
        self.preview = preview
        self.editorState = editorState
        self.controlState = controlState
        self.timeLineGenerator = timeLineGenerator
    }
    
    var body: some View {
        VStack(spacing: 0) {
            VideoEditorControls(
                editorState: editorState,
                controlState: controlState
            )
            
            VideoEditorTimeLine(
                timeLineGenerator: timeLineGenerator,
                preview: preview
            )
                .frame(maxWidth: .infinity, maxHeight: 135)
        }
        .frame(maxWidth: .infinity)
        .background(Color.editorControlBackground)
        .roundedCorner(24, corners: [.topLeft, .topRight])
    }
}
