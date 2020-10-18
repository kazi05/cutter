//
//  ColorPickerCollectionViewCell.swift
//  InstaCut
//
//  Created by Kazim Gadjiev on 18.10.2020.
//  Copyright © 2020 Kazim Gajiev. All rights reserved.
//

import UIKit
import FlexColorPicker

class ColorPickerCollectionViewCell: UICollectionViewCell, NibLoadable {

    @IBOutlet weak var colorPicker: RadialPaletteControl!
    
    private lazy var borderLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = nil
        layer.strokeColor = UIColor.white.cgColor
        layer.lineWidth = 1
        layer.opacity = 0
        return layer
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.addSublayer(borderLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layer.cornerRadius = bounds.height / 2
        contentView.clipsToBounds = true
        
        let path = UIBezierPath(ovalIn: bounds).cgPath
        borderLayer.path = path
    }
    
    override var isSelected: Bool {
        didSet {
            borderLayer.opacity = isSelected ? 1 : 0
        }
    }
    
    func setColor(color: UIColor, isLastCell: Bool) {
        if isLastCell {
            colorPicker.isHidden = false
        } else {
            contentView.backgroundColor = color
        }
    }

}
