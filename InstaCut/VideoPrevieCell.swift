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
    
    override var isSelected : Bool {
        didSet {
            previewImage.layer.borderWidth = isSelected ? 3.0 : 0
        }
    }
    
}
