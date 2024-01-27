//
//  VideoEditorPlayer.swift
//  Cutter
//
//  Created by Гаджиев Казим on 01.01.2024.
//

import SwiftUI

struct VideoPreviewControls: View {
    
    let isPlaying: Bool
    var playPauseTapped: ((Bool) -> Void)
    
    var body: some View {
        Button(action: {
            playPauseTapped(!isPlaying)
        }, label: {
            Image(systemName: isPlaying ? "pause" : "play.fill")
        })
    }
}
