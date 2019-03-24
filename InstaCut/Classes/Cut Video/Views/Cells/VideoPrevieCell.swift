//
//  VideoPrevieCell.swift
//  InstaCut
//
//  Created by Kazim Gajiev on 16.02.2018.
//  Copyright © 2018 Kazim Gajiev. All rights reserved.
//

import UIKit

class VideoPrevieCell: UICollectionViewCell {
    
    
    @IBOutlet weak var previewImage: UIImageView!
    
    @IBOutlet weak var startDuration: UILabel!
    @IBOutlet weak var endDuration: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        previewImage.layer.cornerRadius = 5.0
        previewImage.clipsToBounds = true
    }
    
    func set(startTime: String, and endTime: String) {
        self.startDuration.text = startTime
        self.endDuration.text = endTime
    }
    
    func set(previewImage image: UIImage) {
        self.previewImage.image = image
    }
    
}
