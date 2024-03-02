//
//  VideoThumbnailCacheManager.swift
//  Cutter
//
//  Created by Гаджиев Казим on 02.03.2024.
//

import UIKit

final class VideoThumbnailCacheManager {
    static let shared = VideoThumbnailCacheManager()
    
    private var thumbnailsCache = NSCache<NSString, UIImage>()

    func store(_ image: UIImage, at id: String) {
        thumbnailsCache.setObject(image, forKey: id as NSString)
    }

    func fetch(at id: String) -> UIImage? {
        thumbnailsCache.object(forKey: id as NSString)
    }
}
