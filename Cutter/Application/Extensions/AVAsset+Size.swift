//
//  AVAsset+Size.swift
//  Cutter
//
//  Created by Гаджиев Казим on 01.01.2024.
//

import AVKit
import Foundation

extension AVAsset {
    var videoSize: CGSize? {
        get async throws {
            guard let track = try await loadTracks(withMediaType: .video).first else { return nil }
            let size = try await track.load(.naturalSize)
            return size
        }
    }
}
