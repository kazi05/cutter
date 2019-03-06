//
//  VideoPeriods.swift
//  InstaCut
//
//  Created by Kazim Gajiev on 06/03/2019.
//  Copyright © 2019 Kazim Gajiev. All rights reserved.
//

import UIKit

class VideoPeriods {
    
    var start: Double
    var end: Double
    var previewImage: UIImage
    
    init(start: Double, end: Double, image: UIImage) {
        self.start = start
        self.end = end
        self.previewImage = image
    }
    
}
