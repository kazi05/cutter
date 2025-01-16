//
//  VideoThumbnailService.swift
//  Cutter
//
//  Created by Гаджиев Казим on 19.02.2024.
//

import Photos
import UIKit
import SwiftUI

protocol VideoThumbnailService {
    func getAssetThumnail(
        from asset: PHAsset,
        completion: @escaping (AssetThumbnailGenerator?) -> Void
    ) -> PHImageRequestID

    func cancelRequest(_ requestID: PHImageRequestID)
}

//MARK: - DependencyValues

extension EnvironmentValues {

    var videoThumbnailService: VideoThumbnailService {
        get { self[VideoThumbnailServiceKey.self] }
        set { self[VideoThumbnailServiceKey.self] = newValue }
    }

    private struct VideoThumbnailServiceKey: EnvironmentKey {
        static var defaultValue: VideoThumbnailService {
            VideoThumbnailServiceImpl()
        }
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

    func getAssetThumnail(
        from asset: PHAsset,
        completion: @escaping (AssetThumbnailGenerator?) -> Void
    ) -> PHImageRequestID {
        let requestID = imageManager.requestAVAsset(forVideo: asset, options: options) { (avAsset, _, _) in
            guard let avAsset else {
                completion(nil)
                return
            }
            let model = AssetThumbnailGenerator(id: asset.localIdentifier, asset: avAsset)
            completion(model)
        }
        return requestID
    }

    func cancelRequest(_ requestID: PHImageRequestID) {
        imageManager.cancelImageRequest(requestID)
    }
}

