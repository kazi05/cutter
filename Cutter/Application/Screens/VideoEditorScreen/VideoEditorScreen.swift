//
//  VideoEditorScreen.swift
//  Cutter
//
//  Created by Гаджиев Казим on 28.12.2023.
//

import SwiftUI
import AVKit

struct VideoEditorScreen: View {
    let video: VideoModel
    
    @State private var player = AVPlayer()
    
    var body: some View {
        VStack {
            VideoPlayer(player: player)
        }
        .onAppear {
            player = AVPlayer(playerItem: AVPlayerItem(asset: video.asset))
        }
    }
}
