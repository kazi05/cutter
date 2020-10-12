//
//  PhotoLibraryManager.swift
//  InstaCut
//
//  Created by Kazim Gadjiev on 12.10.2020.
//  Copyright © 2020 Kazim Gajiev. All rights reserved.
//

import UIKit
import Photos

protocol PhotoLibraryManagerType {
    func fetchVideoFromLibrary(onSuccess: @escaping ([VideoModel]) -> Void,
                               onError: @escaping (String) -> Void)
}

class PhotoLibraryManager: PhotoLibraryManagerType {
    
    func fetchVideoFromLibrary(onSuccess: @escaping ([VideoModel]) -> Void,
                               onError: @escaping (String) -> Void
    ) {
        PhotoLibraryPremission().getPhotolibraryAccesStatus { (status) in
            switch status {
            case .error(let errorString):
                onError(errorString)
                
            case .success:
                let options = PHFetchOptions()
                options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
                
                let fetchResult = PHAsset.fetchAssets(with: .video, options: options)
                
                guard fetchResult.count > 0 else {
                    onError(.localized("PH_ZERO_COUNT"))
                    return
                }
                
                var videoModels: [VideoModel] = []
                
                let group = DispatchGroup()
                
                fetchResult.enumerateObjects { (asset, index, bool) in
                    let imageManager = PHCachingImageManager()
                    group.enter()
                    imageManager.requestAVAsset(forVideo: asset, options: nil) { (asset, _, _) in
                        guard let asset = asset else { return }
                        videoModels.append(VideoModel(asset: asset))
                        group.leave()
                    }
                    group.wait()
                }
                
                group.notify(queue: .main) {
                    onSuccess(videoModels)
                }
            }
        }
    }
    
}
