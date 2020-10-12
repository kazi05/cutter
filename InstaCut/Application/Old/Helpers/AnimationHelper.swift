//
//  AnimationHelper.swift
//  InstaCut
//
//  Created by Kazim Gajiev on 24/03/2019.
//  Copyright © 2019 Kazim Gajiev. All rights reserved.
//

import UIKit

class AnimationHelper {
    static public func animateIn(duration: TimeInterval, completion: @escaping () -> Void) {
        UIView.animate(withDuration: duration) {
            completion()
        }
    }
    
    static public func animateOut(duration: TimeInterval, completion: @escaping () -> Void) {
        UIView.animate(withDuration: duration) {
            completion()
        }
    }
}

