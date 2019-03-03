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
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                
                let fetchResult = PHAsset.fetchAssets(with: .video, options: fetchOptions)
                
                if fetchResult.count > 0 {
                    var result = [VideoModel]()
                    for i in 0..<fetchResult.count {
                        let asset = fetchResult.object(at: i)
                        let width = (viewController.view.frame.width / 3) - 10
                        let height = (viewController.view.frame.width / 3) - 10
                        let size = CGSize(width: width, height: height)
                        PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: nil, resultHandler: { (image, userInfo) in
                            let video = VideoModel(image: image ?? #imageLiteral(resourceName: "Cutter-maska.png"), duration: asset.duration)
                            result.append(video)
                        })
                    }
                    completion(nil, result)
                }else {
                    completion("Нет видеофайлов в библиотеке", nil)
                }
            }
        }
    }
}
