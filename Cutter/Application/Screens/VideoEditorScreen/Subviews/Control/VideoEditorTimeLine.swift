//
//  VideoEditorTimeLine.swift
//  Cutter
//
//  Created by Гаджиев Казим on 29.01.2024.
//

import SwiftUI
import AVFoundation
import Combine

struct VideoEditorTimeLine: View {
    @ObservedObject private var state: VideoEditorTimeLineState

    @Environment(\.safeAreaInsets) private var safeAreaInsets

    @State private var videoDuration: CMTime = .zero
    @State private var frameStepSeconds: Double = 10
    @State private var lastFrameStepSeconds: Double = 10
    @State private var frameStepScale: CGFloat = 1
    @State private var lastFrameStepScale: CGFloat = 1
    @State private var contentOffset: CGPoint = .zero
    @State private var contentSize: CGSize = .zero
    
    init(state: VideoEditorTimeLineState) {
        self.state = state
    }
    
    var body: some View {
        GeometryReader { gr in
            let parentWidth = gr.size.width
            let frameSize = CGSize(width: gr.size.height * max(1, frameStepScale), height: gr.size.height)
            let horizontalInset = parentWidth / 2
            UIKScrollView(
                .horizontal,
                contentSize: contentSize,
                showsIndicators: false, 
                contentOffset: contentOffset,
                contentInset: .init(top: 0, left: horizontalInset, bottom: 0, right: horizontalInset)) {
                    LazyHGrid(rows: [.init(.fixed(frameSize.height), spacing: 0)], spacing: 0, content: {
                        ForEach(state.timeLineGenerator.thumbnails, id: \.id) { thumb in
                            Image(uiImage: thumb.image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: frameSize.width)
                        }
                    })
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.accent, lineWidth: 4)
                    )
            }
                .onIsScrolling { isScrolling in
                    if isScrolling {
                        state.pause()
                    }
                }
                .onOffsetChanged { offset in
                    guard offset.x > 0 else { return }
                    let frameWidth = gr.size.height * max(1, frameStepScale)
                    let seconds = offset.x / frameWidth * frameStepSeconds
                    let time = CMTime(seconds: seconds, preferredTimescale: CMTimeScale(NSEC_PER_SEC))

                    state.seek(to: time)
                }
            .onReceive(state.timeLineGenerator.$thumbnails, perform: { thumbnails in
                let width = CGFloat(thumbnails.count) * frameSize.width
                contentSize = .init(width: width, height: frameSize.height)
            })
            .onReceive(state.$time) { time in
                let xOffset = (time.seconds * frameSize.width) / frameStepSeconds - horizontalInset
                contentOffset = .init(x: xOffset, y: 0)
            }
            .overlay {
                Capsule(style: .circular)
                    .fill(.white)
                    .frame(width: 3)
                    .frame(maxHeight: .infinity)
            }
            .simultaneousGesture(
                MagnificationGesture()
                    .onChanged { value in
                        let formattedValue = value < 1 ? (value - 1) * 10 : value
                        let value = lastFrameStepScale + formattedValue
                        let scale = 1 + value.truncatingRemainder(dividingBy: 1)
                        frameStepScale = scale
                        let width = CGFloat((state.timeLineGenerator.thumbnails).count) * frameSize.width
                        contentSize = .init(width: width, height: frameSize.height)
                        let stepSeconds = lastFrameStepSeconds - (value - 1).rounded(.down)
                        if frameStepSeconds != stepSeconds && stepSeconds < videoDuration.seconds / 4 {
                            frameStepSeconds = max(1, stepSeconds)
                            Task.do {
                                try await generateTimeline()
                            } catch: { error in
                                fatalError(error.localizedDescription)
                            }
                        }
                    }
                    .onEnded { value in
                        let formattedValue = value < 1 ? (value - 1) * 10 : value
                        lastFrameStepScale = 1 + formattedValue.truncatingRemainder(dividingBy: 1)
                        lastFrameStepSeconds -= (formattedValue - 1).rounded(.down)
                    }
            )
        }
        .padding(.horizontal, 16)
        .padding(.bottom, safeAreaInsets.bottom)
        .padding(.top, 30)
        .overlay(alignment: .top, content: {
            Text(state.time.formatted("m:s:ms"))
                .frame(maxWidth: .infinity)
        })
        .onFirstAppear {
            Task.do {
                videoDuration = try await state.timeLineGenerator.asset.load(.duration)
                try await generateTimeline()
            } catch: { error in
                fatalError(error.localizedDescription)
            }
        }
    }
    
    private func generateTimeline() async throws {
        let times = stride(from: CMTime.zero, to: videoDuration, by: frameStepSeconds).map { $0 }
        try await state.timeLineGenerator.generateThumbnails(at: times)
    }
}
