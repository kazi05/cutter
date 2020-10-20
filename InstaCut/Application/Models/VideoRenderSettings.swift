//
//  VideoRenderSettings.swift
//  InstaCut
//
//  Created by Kazim Gadjiev on 18.10.2020.
//  Copyright © 2020 Kazim Gajiev. All rights reserved.
//

import Foundation

class VideoRenderSettings {
    
    var needMask: Bool {
        return !IAPManager.shared.purchasedProducts.contains(.mask)
    }
    
    var progressSettings: VideoProgressSettings?
    
}
