//
//  VideoThumbCollectionViewCell.swift
//  InstaCut
//
//  Created by Kazim Gadjiev on 12.10.2020.
//  Copyright © 2020 Kazim Gajiev. All rights reserved.
//

import UIKit

class VideoThumbCollectionViewCell: UICollectionViewCell, NibLoadable {

    @IBOutlet weak var videoDurationLabel: UILabel!
    @IBOutlet weak var videoThumbImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.cornerRadius = 4
        contentView.clipsToBounds = true
    }
    
    func configure(with video: VideoModel) {
        videoDurationLabel.text = video.durationTimeString
        videoThumbImageView.image = video.image
    }

}
