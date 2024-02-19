//
//  VideoModel.swift
//  Cutter
//
//  Created by Гаджиев Казим on 26.12.2023.
//

import UIKit
import Photos

struct VideoThumbnail: Identifiable, Hashable {
    let id: String
    let asset: PHAsset
}
