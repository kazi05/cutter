//
//  VideoEditorControlContainer.swift
//  Cutter
//
//  Created by Гаджиев Казим on 25.01.2024.
//

import SwiftUI

struct VideoEditorControlContainer: View {
    @ObservedObject private var preview: VideoPreviewPlayer
    
    @State private var spaceHeight: CGFloat = 50
    
    init(preview: VideoPreviewPlayer) {
        self.preview = preview
    }
    
    var body: some View {
        VStack {
            VideoPreviewControls(isPlaying: preview.state == .play) { play in
                play ? preview.play() : preview.pause()
            }
            Spacer()
                .frame(height: spaceHeight)
        }
        .frame(maxWidth: .infinity)
        .background(Color.editorControlBackground)
        .onTapGesture {
            withAnimation {
                spaceHeight = 200
            }
        }
    }
}
