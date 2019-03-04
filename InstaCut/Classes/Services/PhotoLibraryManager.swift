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
                
                DispatchQueue.main.async {
                    if fetchResult.count > 0 {
                        var result = [VideoModel]()
                        for i in 0..<fetchResult.count {
                            let asset = fetchResult.object(at: i)
//                            let width = (viewController.view.frame.width / 3) - 10
//                            let height = (viewController.view.frame.width / 3) - 10
//                            let size = CGSize(width: width, height: height)
                            let video = VideoModel(asset: asset)
                            result.append(video)
                        }
                        completion(nil, result)
                    }else {
                        completion("Нет видеофайлов в библиотеке", nil)
                    }
                }
            }
        }
    }
}
