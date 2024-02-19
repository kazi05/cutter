//
//  VideoThumbnailService.swift
//  Cutter
//
//  Created by Гаджиев Казим on 19.02.2024.
//

import Photos
import Dependencies

protocol VideoThumbnailService {
    func getAssetThumnail(from asset: PHAsset) async -> AssetThumbnailGenerator
}

//MARK: - DependencyValues

extension DependencyValues {

    var videoThumbnailService: VideoThumbnailService {
        get { self[VideoThumbnailServiceKey.self] }
        set { self[VideoThumbnailServiceKey.self] = newValue }
    }

    enum VideoThumbnailServiceKey: DependencyKey {
        public static let liveValue: VideoThumbnailService = VideoThumbnailServiceImpl()
    }
}

final class VideoThumbnailServiceImpl: VideoThumbnailService {
    private let imageManager = PHCachingImageManager()
    private let options: PHVideoRequestOptions = {
        let options = PHVideoRequestOptions()
        options.deliveryMode = .fastFormat
        options.version = .current
        return options
    }()

    init() {
        print("Thumbnail service inited")
    }

    func getAssetThumnail(from asset: PHAsset) async -> AssetThumbnailGenerator {
        return await withCheckedContinuation { continuation in
            imageManager.requestAVAsset(forVideo: asset, options: options) { (avAsset, _, _) in
                guard let avAsset else {
                    return
                }
                let model = AssetThumbnailGenerator(asset: avAsset)
                continuation.resume(returning: model)
            }
        }
    }
}

