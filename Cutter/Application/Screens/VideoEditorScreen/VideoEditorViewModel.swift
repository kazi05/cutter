//
//  VideoEditorViewModel.swift
//  Cutter
//
//  Created by Гаджиев Казим on 01.01.2024.
//

import AVFoundation
import SwiftUI
import Combine

final class VideoEditorViewModel: ObservableObject {
    let video: VideoModel
    
    @State private(set) var preview: VideoPreviewPlayer
    
    private var subscriptions = Set<AnyCancellable>()
    
    init(video: VideoModel) {
        self.video = video
        self.preview = .init(asset: video.asset)
    }
}
