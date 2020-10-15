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
    @IBOutlet weak var doneImage: UIImageView!
    
    private lazy var progressCircle: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = nil
        layer.strokeColor = UIColor.red.withAlphaComponent(0.7).cgColor
        layer.strokeEnd = 0
        layer.anchorPoint = CGPoint(x: 0, y: 0)
        return layer
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.cornerRadius = 10
        contentView.clipsToBounds = true
        contentView.layer.addSublayer(progressCircle)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let path = UIBezierPath(arcCenter: contentView.center,
                                radius: 15,
                                startAngle: -CGFloat.pi / 2,
                                endAngle: 3 * CGFloat.pi / 2,
                                clockwise: true)
        progressCircle.path = path.cgPath
        progressCircle.lineWidth = 15
    }

    func configure(with thumb: UIImage, completed: Bool) {
        thumbImageView.image = thumb
        
        doneImage.transform = completed ? .identity : CGAffineTransform(scaleX: 0, y: 0)
        progressCircle.strokeEnd = completed ? 1 : 0
    }
    
    func progressChanged(_ progress: Float) {
        progressCircle.strokeEnd = CGFloat(progress)
    }
    
    func progressCompleted() {
        UIView.animate(withDuration: 0.3) {
            self.doneImage.transform = .identity
        }
    }

}
