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
    func fetchVideoFromLibrary(completion: @escaping (Result<[VideoModel], Error>) -> Void)
    
    func saveVideoToPhotoLibrary(from url: URL, completed: @escaping (Result<Bool, Error>) -> Void)
}

class PhotoLibraryManager: PhotoLibraryManagerType {
       
    func fetchVideoFromLibrary(completion: @escaping (Result<[VideoModel], Error>) -> Void) {
        PhotoLibraryPremission().getPhotolibraryAccesStatus { (status) in
            switch status {
            case .error(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                
            case .success:
                let options = PHFetchOptions()
                options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
                options.predicate = NSPredicate(format: "duration > %f", 60.0)
                
                let fetchResult = PHAsset.fetchAssets(with: .video, options: options)
                
                guard fetchResult.count > 0 else {
                    DispatchQueue.main.async {
                        completion(.failure(PhotoAuthorizationError.empty))
                    }
                    return
                }
                
                var videoModels: [VideoModel] = []
                
                let group = DispatchGroup()
                
                fetchResult.enumerateObjects { (asset, index, bool) in
                    let imageManager = PHCachingImageManager()
                    group.enter()
                    imageManager.requestAVAsset(forVideo: asset, options: nil) { (asset, _, _) in
                        guard let asset = asset else { return }
                        let assetImage = AssetImageGenerator(asset: asset).generateImage()
                        videoModels.append(VideoModel(asset: asset, image: assetImage))
                        group.leave()
                    }
                    group.wait()
                }
                
                group.notify(queue: .main) {
                    completion(.success(videoModels))
                }
            }
        }
    }
    
    func saveVideoToPhotoLibrary(from url: URL, completed: @escaping (Result<Bool, Error>) -> Void) {
        PhotoLibraryPremission().getPhotolibraryAccesStatus { (status) in
            switch status {
            case .error(let error):
                DispatchQueue.main.async {
                    completed(.failure(error))
                }
                
            case .success:
                PHPhotoLibrary.shared().performChanges {
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
                } completionHandler: { (saved, error) in
                    if let error = error {
                        completed(.failure(error))
                        return
                    }
                    completed(.success(saved))
                }

            }
        }
    }
    
}
