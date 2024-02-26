//
//  VideoEditorPreview.swift
//  Cutter
//
//  Created by Гаджиев Казим on 01.01.2024.
//

import SwiftUI
import AVKit
import SafeSFSymbols

struct VideoEditorPreview: View {
    
    @ObservedObject var preview: VideoEditorPreviewState

    @State private var videoSize: CGSize = .zero
    
    var body: some View {
        GeometryReader { gr in
            ZStack {
                Color.clear
                let size = gr.size
                let widthRatio = size.width / videoSize.width
                let heightRatio = size.height / videoSize.height
                let scale = min(widthRatio, heightRatio)
                let padding: CGFloat = 10
                let previewWidth = max(100, videoSize.width * scale - (padding * 2))
                let previewHeight = max(100, videoSize.height * scale - (padding * 2))

                MetalVideoView(
                    renderer: preview.renderer,
                    state: preview.playerState, 
                    seekedTime: preview.seekedTime,
                    device: preview.renderer.device
                )
                    .onFirstAppear {
                        let size = preview.getVideoSize()
                        videoSize = size
                    }
                    .frame(width: previewWidth, height: previewHeight)
                    .clipShape(RoundedRectangle(cornerSize: .init(width: 8, height: 8)))
            }
        }
        .id(Unmanaged.passUnretained(preview).toOpaque())
    }
}
