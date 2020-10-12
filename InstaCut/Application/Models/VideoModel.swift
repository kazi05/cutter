//
//  VideoModel.swift
//  InstaCut
//
//  Created by Kazim Gajiev on 03/03/2019.
//  Copyright © 2019 Kazim Gajiev. All rights reserved.
//

import UIKit
import AVFoundation

struct VideoModel {
    
    let asset: AVAsset
    
    var durationTimeString: String {
        return String(format: "%02d:%02d",Int((asset.duration.seconds / 60)),Int(asset.duration.seconds.rounded()) % 60)
    }
}
