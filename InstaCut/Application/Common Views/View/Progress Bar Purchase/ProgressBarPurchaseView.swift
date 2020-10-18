//
//  ProgressBarPurchaseView.swift
//  InstaCut
//
//  Created by Kazim Gadjiev on 18.10.2020.
//  Copyright © 2020 Kazim Gajiev. All rights reserved.
//

import UIKit

class ProgressBarPurchaseView: UIView, NibLoadable {

    @IBOutlet weak var previewImageView: UIImageView!
    
    private let wide: CGFloat = 10
    
    private lazy var progressLayer: CAShapeLayer = {
        let progressLayer = CAShapeLayer()
        progressLayer.fillColor = nil
        progressLayer.strokeColor = UIColor(named: "appMainColor")?.cgColor
        progressLayer.strokeEnd = 1
        progressLayer.lineWidth = wide
        return progressLayer
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: bounds.height - wide / 2))
        path.addLine(to: CGPoint(x: bounds.width, y: bounds.height - wide / 2))
        
        progressLayer.path = path.cgPath
    }
    
    func setPreview(from period: VideoPeriod) {
        previewImageView.image = period.previewImage
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.addProgressBar()
        }
    }
    
    private func addProgressBar() {
        layer.addSublayer(progressLayer)
        progressLayer.addProgressAnimation(repeated: true)
    }
}
