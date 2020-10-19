//
//  VideoPeriodsCollectionView.swift
//  InstaCut
//
//  Created by Kazim Gadjiev on 13.10.2020.
//  Copyright © 2020 Kazim Gajiev. All rights reserved.
//

import UIKit

class VideoPeriodsCollectionView: UICollectionView {

    private lazy var borderView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.borderWidth = 4
        view.layer.borderColor = UIColor(named: "appMainColor")?.cgColor
        view.alpha = 0
        return view
    }()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addSubview(borderView)
        
        borderView.layer.cornerRadius = 4
    }
    
    public func setBorderView(with frame: CGRect) {
        borderView.frame = frame
        UIView.animate(withDuration: 0.2) {
            self.borderView.alpha = 1
        }
    }
    
    func moveBorderView(to center: CGPoint, animated: Bool = true) {
        let animationBlock = { [weak self] in
            self?.borderView.center = center
        }
        
        if animated {
            UIView.animate(withDuration: 0.3) {
                animationBlock()
            }
        } else {
            animationBlock()
        }
    }

}
