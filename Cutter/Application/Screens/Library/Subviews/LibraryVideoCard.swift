//
//  LibraryVideoCard.swift
//  Cutter
//
//  Created by Гаджиев Казим on 26.12.2023.
//

import SwiftUI

struct LibraryVideoCard: View {
    let video: VideoModel
    
    @State private var videoDuration: String = ""
    
    var body: some View {
        GeometryReader { geometry in
            Image(uiImage: video.image)
                .resizable()
                .scaledToFill()
                .frame(height: geometry.size.width)
                .clipShape(RoundedRectangle(cornerSize: .init(width: 4, height: 4)))
                .overlay(alignment: .bottom) {
                    ZStack {
                        LinearGradient(colors: [Color.black, Color.clear], startPoint: .bottom, endPoint: .top)
                        Text(videoDuration)
                            .foregroundStyle(.white)
                            .font(.caption)
                            .frame(width: geometry.size.width)
                            .multilineTextAlignment(.leading)
                    }
                    .frame(height: 30)
                }
        }
        .task {
            do {
                videoDuration = try await video.durationTimeString
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
