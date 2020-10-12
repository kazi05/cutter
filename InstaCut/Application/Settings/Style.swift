//
//  Style.swift
//  InstaCut
//
//  Created by Kazim Gadjiev on 12.10.2020.
//  Copyright © 2020 Kazim Gajiev. All rights reserved.
//

import UIKit

class Style {
    
    static func stylizeNavigationBar() {
        let textAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18, weight: .bold)
        ]
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            
            appearance.shadowImage = nil
            appearance.backgroundColor = UIColor(named: "navBarColor")
            appearance.titleTextAttributes = textAttributes

            UINavigationBar.appearance().scrollEdgeAppearance = appearance
            UINavigationBar.appearance().standardAppearance = appearance;
            UINavigationBar.appearance().compactAppearance = appearance;
        } else {
            UINavigationBar.appearance().shadowImage = UIImage()
            UINavigationBar.appearance().barTintColor = UIColor(named: "navBarColor")

            UINavigationBar.appearance().titleTextAttributes = textAttributes
            UINavigationBar.appearance().largeTitleTextAttributes = textAttributes
        }
        
        UINavigationBar.appearance().isTranslucent = false
    }
    
}
