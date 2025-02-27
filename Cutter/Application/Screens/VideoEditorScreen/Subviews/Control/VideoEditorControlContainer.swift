//
//  VideoEditorControlContainer.swift
//  Cutter
//
//  Created by Гаджиев Казим on 25.01.2024.
//

import SwiftUI

struct VideoEditorControlContainer: View {
    @ObservedObject private var editorState: VideoEditorState

    init(editorState: VideoEditorState) {
        self.editorState = editorState
    }
    
    var body: some View {
        VStack(spacing: 0) {
            VideoEditorControls(state: editorState)
                .id(Unmanaged.passUnretained(editorState).toOpaque())

            VideoEditorTimeLine(state: editorState.timeLineState)
                .id(Unmanaged.passUnretained(editorState).toOpaque())
                .frame(maxWidth: .infinity, maxHeight: 135)
        }
        .frame(maxWidth: .infinity)
        .background(Color.editorControlBackground)
        .roundedCorner(24, corners: [.topLeft, .topRight])
    }
}
