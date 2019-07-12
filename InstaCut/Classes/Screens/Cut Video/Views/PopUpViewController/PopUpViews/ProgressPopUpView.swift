//
//  ProgressPopUpView.swift
//  InstaCut
//
//  Created by Kazim Gajiev on 28/03/2019.
//  Copyright © 2019 Kazim Gajiev. All rights reserved.
//

import UIKit
import JGProgressHUD

class ProgressPopUpView: UIView, NibLoadable {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let HUD = JGProgressHUD(style: .dark)
        HUD.indicatorView = JGProgressHUDIndicatorView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
