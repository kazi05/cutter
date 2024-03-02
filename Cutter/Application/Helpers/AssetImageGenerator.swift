//
//  AssetImageGenerator.swift
//  Cutter
//
//  Created by Гаджиев Казим on 26.12.2023.
//

import UIKit.UIImage
import AVFoundation

final class AssetThumbnailGenerator {

    private let id: String
    private let asset: AVAsset
    private let cache = VideoThumbnailCacheManager.shared

    init(id: String, asset: AVAsset) {
        self.id = id
        self.asset = asset
    }

    var videoDuration: String {
        get async throws {
            let duration = try await asset.load(.duration)
            return duration.formatted()
        }
    }

    func generateImage(
        from startTime: CMTime = .init(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
    ) async -> UIImage {
        await withCheckedContinuation { continuation in
            if let image = cache.fetch(at: id) {
                continuation.resume(returning: image)
                return
            }
            DispatchQueue.global(qos: .userInitiated).async {
                let imageGenerator = AVAssetImageGenerator(asset: self.asset)
                imageGenerator.appliesPreferredTrackTransform = true
                imageGenerator.requestedTimeToleranceBefore = startTime
                imageGenerator.requestedTimeToleranceAfter = startTime

                do {
                    let imageRef = try imageGenerator.copyCGImage(at: startTime, actualTime: nil)
                    let image = UIImage(cgImage: imageRef)
                    self.cache.store(image, at: self.id)
                    continuation.resume(returning: image)
                } catch {
                    continuation.resume(returning: UIImage())
                }
            }
        }
    }
}
