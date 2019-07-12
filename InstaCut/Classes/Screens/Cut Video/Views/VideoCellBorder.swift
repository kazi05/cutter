//
//  VideoCellBorder.swift
//  InstaCut
//
//  Created by Kazim Gajiev on 24/03/2019.
//  Copyright © 2019 Kazim Gajiev. All rights reserved.
//

import UIKit

class VideoCellBorder: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    override func layoutSubviews() {
        setBorder()
    }
    
    private func setBorder() {
        layer.borderColor = #colorLiteral(red: 0.8429999948, green: 0.2779999971, blue: 0.0549999997, alpha: 1)
        layer.borderWidth = 3.0
        layer.cornerRadius = 5.0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
