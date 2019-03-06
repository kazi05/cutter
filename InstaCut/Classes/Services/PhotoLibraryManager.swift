//
//  PhotoLibraryManager.swift
//  InstaCut
//
//  Created by Kazim Gajiev on 03/03/2019.
//  Copyright © 2019 Kazim Gajiev. All rights reserved.
//

import Photos
import UIKit

protocol PhotoLibraryProtocol: class {
    func fetchVideosFromPhotolibrary(_ viewController: UIViewController, completion: @escaping (String?, [VideoModel]?) -> Void)
}

class PhotoLibraryManager: PhotoLibraryProtocol {
    
    func fetchVideosFromPhotolibrary(_ viewController: UIViewController, completion: @escaping (String?, [VideoModel]?) -> Void) {
        PhotoLibraryPremission.shared.getPhotolibraryAccesStatus { (status) in
            switch status {
            case .error(let error):
                completion(error, nil)
            case .succes:
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
                
                let fetchResult = PHAsset.fetchAssets(with: .video, options: fetchOptions)
                
                if fetchResult.count > 0 {
                    var result = [VideoModel]()
                    for i in 0..<fetchResult.count {
                        let asset = fetchResult.object(at: i)
                        //                            let width = (viewController.view.frame.width / 3) - 10
                        //                            let height = (viewController.view.frame.width / 3) - 10
                        //                            let size = CGSize(width: width, height: height)
                        if let image = self.getImage(from: asset), let videoURL = self.getURL(from: asset) {
                            let video = VideoModel(asset: asset, image: image, videoURL: videoURL)
                            result.append(video)
                        }
                    }
                    completion(nil, result)
                }else {
                    completion("Нет видеофайлов в библиотеке", nil)
                }
            }
        }
    }
    
    private func getImage(from asset: PHAsset) -> UIImage? {
        var img: UIImage?
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.version = .original
        options.isSynchronous = true
        manager.requestImageData(for: asset, options: options) { data, _, _, _ in
            if let data = data {
                img = UIImage(data: data)
            }
        }
        return img
    }
    
    private func getURL(from asset: PHAsset) -> URL? {
        var url: URL?
        let manager = PHImageManager.default()
        let semaphore = DispatchSemaphore.init(value: 0)
        let options = PHVideoRequestOptions()
        options.version = .original

        manager.requestAVAsset(forVideo: asset, options: options) { (avasset, audioMix, userInfo) in
            if let urlAsset = avasset as? AVURLAsset {
                let localVideoUrl: URL = urlAsset.url as URL
                url = localVideoUrl
                semaphore.signal()
            }
        }
        
        semaphore.wait()
        
        return url
    }
}
