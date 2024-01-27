//
//  AVAsset+Size.swift
//  Cutter
//
//  Created by Гаджиев Казим on 01.01.2024.
//

import AVKit
import Foundation

extension AVAsset {
    func videoSize() async throws -> CGSize? {
        guard let track = try await loadTracks(withMediaType: .video).first else { return nil }
        let size = try await track.load(.naturalSize)
        return size
    }
}
