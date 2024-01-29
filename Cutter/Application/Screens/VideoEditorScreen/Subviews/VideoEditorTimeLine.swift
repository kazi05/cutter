//
//  VideoEditorTimeLine.swift
//  Cutter
//
//  Created by Гаджиев Казим on 29.01.2024.
//

import SwiftUI
import AVFoundation

struct VideoEditorTimeLine: View {
    @ObservedObject private var timeLineGenerator: VideoTimeLineGenerator
    @ObservedObject private var preview: VideoPreviewPlayer
    
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    @State private var videoDuration: CMTime = .zero
    @State private var contentOffset: CGPoint = .zero
    @State private var contentSize: CGSize = .zero
    @State private var isScrolling = false
    
    init(
        timeLineGenerator: VideoTimeLineGenerator,
        preview: VideoPreviewPlayer
    ) {
        self.timeLineGenerator = timeLineGenerator
        self.preview = preview
    }
    
    var body: some View {
        GeometryReader { gr in
            UIKScrollView(
                .horizontal,
                contentSize: contentSize,
                showsIndicators: false,
                contentInset: .init(top: 0, left: gr.size.width / 2, bottom: 0, right: gr.size.width / 2),
                onIsScrolling: {
                    isScrolling in
                    print(isScrolling)
                },
                onOffsetChanged: { offset in
                    print(offset)
                }) {
                    LazyHGrid(rows: [.init(.fixed(gr.size.height), spacing: 0)], spacing: 0, content: {
                        ForEach(timeLineGenerator.thumbnails, id: \.id) { thumb in
                            Image(uiImage: thumb.image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: gr.size.height)
                        }
                    })
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.accent, lineWidth: 4)
                    )
            }
            .onReceive(timeLineGenerator.$thumbnails, perform: { thumbnails in
                let width = CGFloat(thumbnails.count) * gr.size.height
                let height = gr.size.height
                contentSize = .init(width: width, height: height)
            })
//            .scrollStatusByIntrospect(
//                isScrolling: $isScrolling,
//                contentOffset: $contentOffset
//            )
//            .overlay(alignment: .center) {
//                VStack {
//                    Text("\(String(describing: contentOffset))")
//                    Text("\(String(describing: contentSize))")
//                    Text("Is scrolling: \(String(isScrolling))")
//                }
//            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, safeAreaInsets.bottom)
        .padding(.top, 10)
        .onFirstAppear {
            Task.do {
                videoDuration = try await timeLineGenerator.asset.load(.duration)
                let times = stride(from: CMTime.zero, to: videoDuration, by: 10).map { $0 }
                try await timeLineGenerator.generateThumbnails(at: times)
            } catch: { error in
                fatalError(error.localizedDescription)
            }

        }
    }
}

extension CMTime: Strideable {
    public func distance(to other: CMTime) -> TimeInterval {
        return TimeInterval((Double(other.value) / Double(other.timescale)) - (Double(self.value) /  Double(self.timescale)))
    }

    public func advanced(by n: TimeInterval) -> CMTime {
        var retval = self
        retval.value += CMTimeValue(n * TimeInterval(self.timescale))
        return retval
    }
}
