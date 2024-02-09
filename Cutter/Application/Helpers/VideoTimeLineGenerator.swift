//
//  VideoTimeLineGenerator.swift
//  Cutter
//
//  Created by Гаджиев Казим on 29.01.2024.
//

import AVFoundation
import UIKit

struct Thumbnail: Identifiable {
    let id = UUID()
    let image: UIImage
    let time: CMTime
}

final class VideoTimeLineGenerator: ObservableObject {
    let asset: VideoAsset
    
    @Published private(set) var thumbnails: [Thumbnail] = []
    
    private var needsToReload: [Thumbnail] = []
    
    init(asset: VideoAsset) {
        self.asset = asset
    }
    
    @MainActor
    func generateThumbnails(
        at times: [CMTime],
        disableTolerance: Bool = false,
        needReloadForTolerance: Bool = true
    ) async throws {
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        let images = try await withThrowingTaskGroup(of: (UIImage, CMTime).self, returning: [Thumbnail].self) { group in

            for time in times {
                group.addTask {
                    try await self.generateThumbnail(
                        imageGenerator: imageGenerator,
                        forTime: time,
                        disableTolerance: disableTolerance
                    )
                }
            }

            var results = [Thumbnail]()
            for try await (image, time) in group {
                results.append(.init(image: image, time: time))
            }
            
            if !disableTolerance && needReloadForTolerance {
                for result in results {
                    if !thumbnails.contains(where: { $0.time == result.time }) {
                        needsToReload.append(result)
                    } else {
                        continue
                    }
                }
            }

            return results.sorted(by: { $0.time < $1.time })
        }
        
        thumbnails = images
        
        if needReloadForTolerance {
            for thumb in needsToReload {
                let (image, time) = try await generateThumbnail(
                    imageGenerator: imageGenerator,
                    forTime: thumb.time,
                    disableTolerance: true
                )
                if let index = thumbnails.firstIndex(where: { $0.time == thumb.time }) {
                    thumbnails[index] = .init(image: image, time: time)
                } else {
                    continue
                }
            }
            needsToReload.removeAll()
        }
    }
    
    private func generateThumbnail(
        imageGenerator: AVAssetImageGenerator,
        forTime time: CMTime,
        disableTolerance: Bool
    ) async throws -> (UIImage, CMTime) {
        if disableTolerance {
            imageGenerator.requestedTimeToleranceBefore = .zero
            imageGenerator.requestedTimeToleranceAfter = .zero
        }
        let (cgImage, newTime) = try await imageGenerator.image(at: time)
        return (UIImage(cgImage: cgImage), disableTolerance ? newTime : time)
    }
}
