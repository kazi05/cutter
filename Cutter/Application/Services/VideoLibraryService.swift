//
//  VideoLibraryService.swift
//  Cutter
//
//  Created by Гаджиев Казим on 26.12.2023.
//

import Photos
import Dependencies

protocol VideoLibraryService {
    func getStatus() async -> MediaAuthorizationStatus
    func getVideos() async -> [VideoModel]
}

//MARK: - DependencyValues

extension DependencyValues {
    
    var videoLibraryService: VideoLibraryService {
        get { self[VideoLibraryServiceKey.self] }
        set { self[VideoLibraryServiceKey.self] = newValue }
    }
    
    enum VideoLibraryServiceKey: DependencyKey {
        public static let liveValue: VideoLibraryService = ViewLibraryServiceImpl()
    }
}

final class ViewLibraryServiceImpl: VideoLibraryService {
    private let permission = MediaLibraryPremission()
    
    func getStatus() async -> MediaAuthorizationStatus {
        await permission.getMedialibraryAccesStatus()
    }
    
    func getVideos() async -> [VideoModel] {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        let fetchResult = PHAsset.fetchAssets(with: .video, options: options)
        
        guard fetchResult.count > 0 else {
            return []
        }
        
        return await withTaskGroup(of: VideoModel.self) { group in
            for index in 0..<fetchResult.count {
                let asset = fetchResult.object(at: index)
                group.addTask {
                    await self.generateVideoModel(for: asset)
                }
            }
            
            var videoModels: [VideoModel] = []
            for await model in group {
                videoModels.append(model)
            }
            return videoModels
        }
    }
    
    private func generateVideoModel(for asset: PHAsset) async -> VideoModel {
        await withCheckedContinuation { continuation in
            let imageManager = PHCachingImageManager()
            imageManager.requestAVAsset(forVideo: asset, options: nil) { (avAsset, _, _) in
                guard let avAsset else { return }
                let assetImage = AssetImageGenerator(asset: avAsset).generateImage()
                let model = VideoModel(id: asset.localIdentifier, asset: avAsset, image: assetImage)
                continuation.resume(returning: model)
            }
        }
    }
}
