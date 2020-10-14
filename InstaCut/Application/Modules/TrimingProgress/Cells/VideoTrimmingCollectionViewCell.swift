//
//  VideoTrimmingCollectionViewCell.swift
//  InstaCut
//
//  Created by Kazim Gadjiev on 14.10.2020.
//  Copyright © 2020 Kazim Gajiev. All rights reserved.
//

import UIKit

class VideoTrimmingCollectionViewCell: UICollectionViewCell, NibLoadable {

    @IBOutlet weak var thumbImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.cornerRadius = 10
        contentView.clipsToBounds = true
    }

    func configure(with thumb: UIImage) {
        thumbImageView.image = thumb
    }
    
}
