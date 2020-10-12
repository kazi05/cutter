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
            
            let hideBackButtonTitleAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.clear
            ]
            
            let normalBackButton = appearance.backButtonAppearance.normal
            let highlightedBackButton = appearance.backButtonAppearance.highlighted
            
            normalBackButton.titleTextAttributes = hideBackButtonTitleAttributes
            highlightedBackButton.titleTextAttributes = hideBackButtonTitleAttributes
            
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
            UINavigationBar.appearance().standardAppearance = appearance;
            UINavigationBar.appearance().compactAppearance = appearance;
        } else {
            UINavigationBar.appearance().shadowImage = UIImage()
            UINavigationBar.appearance().barTintColor = UIColor(named: "navBarColor")
            
            UINavigationBar.appearance().titleTextAttributes = textAttributes
            UINavigationBar.appearance().largeTitleTextAttributes = textAttributes
            
            let BarButtonItemAppearance = UIBarButtonItem.appearance()
            let attributes = [ NSAttributedString.Key.foregroundColor: UIColor.clear]
            
            BarButtonItemAppearance.setTitleTextAttributes(attributes, for: .normal)
            BarButtonItemAppearance.setTitleTextAttributes(attributes, for: .highlighted)
        }
        
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().isTranslucent = false
    }
    
}
