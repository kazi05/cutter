//
//  UserImagesCollectionViewCell.swift
//  InstaCut
//
//  Created by Kazim Gajiev on 15.02.2018.
//  Copyright © 2018 Kazim Gajiev. All rights reserved.
//

import UIKit

class UserImagesCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var videoDuration: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        userImage.layer.cornerRadius = 10.0
        userImage.clipsToBounds = true
    }
    
    func set(image: UIImage, durationText: String?) {
        userImage.image = image
        videoDuration.text = durationText
    }
}
