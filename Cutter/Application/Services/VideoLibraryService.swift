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
    func getVideos() async -> [VideoThumbnail]
}

//MARK: - DependencyValues

extension DependencyValues {
    
    var videoLibraryService: VideoLibraryService {
        get { self[VideoLibraryServiceKey.self] }
        set { self[VideoLibraryServiceKey.self] = newValue }
    }
    
    enum VideoLibraryServiceKey: DependencyKey {
        public static let liveValue: VideoLibraryService = VideoLibraryServiceImpl()
    }
}

final class VideoLibraryServiceImpl: VideoLibraryService {
    private let permission = MediaLibraryPremission()
    
    func getStatus() async -> MediaAuthorizationStatus {
        await permission.getMedialibraryAccesStatus()
    }
    
    func getVideos() async -> [VideoThumbnail] {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        let fetchResult = PHAsset.fetchAssets(with: .video, options: nil)
        
        guard fetchResult.count > 0 else {
            return []
        }
        
        var results = [VideoThumbnail]()
        for index in 0..<fetchResult.count {
            let asset = fetchResult.object(at: index)
            let video = VideoThumbnail(id: asset.localIdentifier, asset: asset)
            results.append(video)
        }
        return results.reversed()
    }
}
