//
//  LibraryVideoCard.swift
//  Cutter
//
//  Created by Гаджиев Казим on 26.12.2023.
//

import SwiftUI
import Dependencies
import Photos
import SafeSFSymbols

struct LibraryVideoCard: View {
    let video: VideoThumbnail
    
    @Dependency(\.videoThumbnailService) private var videoThumbnailService
    @State private var thumbnail: UIImage? = nil
    @State private var videoDuration: String? = nil
    @State private var requestID: PHImageRequestID?

    var body: some View {
        GeometryReader { gr in
            if let thumbnail, let videoDuration {
                Image(uiImage: thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: gr.size.width, height: gr.size.height, alignment: .center)
                    .contentShape(Rectangle())
                    .clipShape(RoundedRectangle(cornerSize: .init(width: 8, height: 8)))
                    .overlay(alignment: .bottom) {
                        ZStack {
                            LinearGradient(colors: [Color.black, Color.clear], startPoint: .bottom, endPoint: .top)
                            Text(videoDuration)
                                .foregroundStyle(.white)
                                .font(.caption)
                                .multilineTextAlignment(.leading)
                        }
                        .frame(height: 30)
                    }
            } else {
                ProgressView()
                    .frame(width: gr.size.width, height: gr.size.height, alignment: .center)
            }
        }
        .onAppear {
            loadVideoData()
        }
        .onDisappear {
            // Освобождение ресурсов
            self.thumbnail = nil
            self.videoDuration = nil
            if let requestID, thumbnail == nil {
                videoThumbnailService.cancelRequest(requestID)
            }
        }
    }

    func loadVideoData() {
        guard thumbnail == nil && videoDuration == nil else { return }
        requestID = videoThumbnailService.getAssetThumnail(from: video.asset) { asset in
            guard let asset else {
                thumbnail = UIImage(.photo.fill)
                return
            }
            Task {
                thumbnail = await asset.generateImage()
                videoDuration = try await asset.videoDuration
                requestID = nil
            }
        }
    }
}
