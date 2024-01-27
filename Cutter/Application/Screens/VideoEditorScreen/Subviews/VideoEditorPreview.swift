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
    @ObservedObject var preview: VideoPreviewPlayer
    
    @State private var videoSize: CGSize = .zero
    
    var body: some View {
        GeometryReader { gr in
            ZStack {
                Color.accentColor
                let size = gr.size
                let widthRatio = size.width / videoSize.width
                let heightRatio = size.height / videoSize.height
                let scale = min(widthRatio, heightRatio)
                let padding: CGFloat = 10
                let previewWidth = max(100, videoSize.width * scale - (padding * 2))
                let previewHeight = max(100, videoSize.height * scale - (padding * 2))
                
                MetalVideoView(
                    renderer: .init(
                        playerItem: preview.playerItem,
                        videoOutput: preview.videoOutput
                    ),
                    state: preview.state
                )
                    .onFirstAppear {
                        Task.do {
                            let size = try await preview.asset.videoSize() ?? .zero
                            videoSize = size
                            print(gr.size, videoSize)
                        } catch: { _ in
                            videoSize = .zero
                        }
                    }
                    .frame(width: previewWidth, height: previewHeight)
            }
        }
    }
}
