//
//  LibraryVideoCard.swift
//  Cutter
//
//  Created by Гаджиев Казим on 26.12.2023.
//

import SwiftUI
import Dependencies

struct LibraryVideoCard: View {
    let video: VideoThumbnail
    
    @Dependency(\.videoThumbnailService) private var videoThumbnailService
    @State private var thumbnail: UIImage? = nil
    @State private var videoDuration: String? = nil

    var body: some View {
        Group {
            if let thumbnail, let videoDuration {
                Image(uiImage: thumbnail)
                    .resizable()
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
            }
        }
        .task {
            do {
                guard thumbnail == nil && videoDuration == nil else { return }
                let asset = await videoThumbnailService.getAssetThumnail(from: video.asset)
                thumbnail = await asset.generateImage()
                videoDuration = try await asset.videoDuration
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
