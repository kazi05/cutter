//
//  CALayer+Ext.swift
//  InstaCut
//
//  Created by Kazim Gadjiev on 18.10.2020.
//  Copyright © 2020 Kazim Gajiev. All rights reserved.
//

import UIKit
import AVFoundation

extension CALayer {
    
    func addProgressAnimation(repeated: Bool, beginTime: CFTimeInterval = .zero, duration: CFTimeInterval = 10) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.beginTime = beginTime
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = duration
        if repeated {
            animation.repeatCount = .infinity
        }
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        
        add(animation, forKey: nil)
    }
    
}

extension CALayer {
    
    func applySketchShadow(
        color: UIColor = .black,
        alpha: Float = 1,
        x: CGFloat = 0,
        y: CGFloat = 2,
        blur: CGFloat = 4,
        spread: CGFloat = 0)
    {
        shadowColor = color.cgColor
        shadowOpacity = alpha
        shadowOffset = CGSize(width: x, height: y)
        shadowRadius = blur / 2.0
        if spread == 0 {
            shadowPath = nil
        } else {
            let dx = -spread
            let rect = bounds.insetBy(dx: dx, dy: dx)
            shadowPath = UIBezierPath(rect: rect).cgPath
        }
    }
}
