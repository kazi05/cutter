//
//  VideoEditorControlContainer.swift
//  Cutter
//
//  Created by Гаджиев Казим on 25.01.2024.
//

import SwiftUI

struct VideoEditorControlContainer: View {
    @ObservedObject private var editorState: VideoEditorState
    @ObservedObject private var controlState: VideoEditorControlState
    
    init(
        editorState: VideoEditorState,
        controlState: VideoEditorControlState
    ) {
        self.editorState = editorState
        self.controlState = controlState
    }
    
    var body: some View {
        VStack {
            VideoEditorControls(
                editorState: editorState,
                controlState: controlState
            )
            
            Spacer()
                .frame(height: 200)
        }
        .frame(maxWidth: .infinity)
        .background(Color.editorControlBackground)
        .roundedCorner(24, corners: [.topLeft, .topRight])
    }
}
