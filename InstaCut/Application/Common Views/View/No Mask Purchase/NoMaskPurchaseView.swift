//
//  NoMaskPurchaseView.swift
//  InstaCut
//
//  Created by Kazim Gadjiev on 18.10.2020.
//  Copyright © 2020 Kazim Gajiev. All rights reserved.
//

import UIKit

class NoMaskPurchaseView: UIView, NibLoadable {

    @IBOutlet weak var imageWithMaskView: UIImageView!
    @IBOutlet weak var imageViewWithoutMask: UIImageView!
    
    func setPreview(from period: VideoPeriod) {
        imageWithMaskView.image = period.previewImage
        imageViewWithoutMask.image = period.previewImage
    }
    
}
