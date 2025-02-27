//
//  VideoRenderProgressView.swift
//  Cutter
//
//  Created by Гаджиев Казим on 25.02.2024.
//

import SwiftUI

struct VideoRenderProgressView: View {
    @ObservedObject private var progressState: VideoRenderProgressState
    @Environment(\.screenSize) private var screenSize

    init(progressState: VideoRenderProgressState) {
        self.progressState = progressState
    }

    var body: some View {
        let rectWidth = max(0, min(400, screenSize.width - 32))
        ZStack {
            Color.black
                .opacity(0.7)

            VStack(spacing: 16) {
                Spacer()
                Text(LocalizedStringResource(stringLiteral: progressState.title))
                Text("\(Int(progressState.progress * 100)) %")
                ProgressView(value: progressState.progress, total: 1.0)
                Spacer()
                Button {
                    progressState.cancelRendering?()
                } label: {
                    Text("RENDER_PROGRESS_CANCEL")
                }
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            .frame(width: rectWidth, height: rectWidth, alignment: .center)
        }
        .ignoresSafeArea()
    }
}
