//
//  UIApplication.swift
//  Cutter
//
//  Created by Гаджиев Казим on 09.04.2024.
//

import UIKit

extension UIApplication {
    var firstKeyWindow: UIWindow? {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { $0.activationState == .foregroundActive }
            .first?.keyWindow
        
    }
}
