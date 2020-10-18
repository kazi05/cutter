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
