//
//  VideoModel.swift
//  InstaCut
//
//  Created by Kazim Gajiev on 03/03/2019.
//  Copyright © 2019 Kazim Gajiev. All rights reserved.
//

import UIKit

struct VideoModel {
    let image: UIImage
    let duration: TimeInterval
    
    var durationTime: String {
        return String(format: "%02d:%02d",Int((duration / 60)),Int(duration.rounded()) % 60)
    }
}
