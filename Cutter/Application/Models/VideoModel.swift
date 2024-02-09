//
//  VideoModel.swift
//  Cutter
//
//  Created by Гаджиев Казим on 26.12.2023.
//

import UIKit
import AVFoundation

typealias VideoAsset = AVAsset

struct VideoModel: Identifiable, Hashable {
    let id: String
    let asset: VideoAsset
    let image: UIImage
    
    var durationTimeString: String {
        get async throws {
            let duration = try await asset.load(.duration)
            return duration.formatted()
        }
    }
}
