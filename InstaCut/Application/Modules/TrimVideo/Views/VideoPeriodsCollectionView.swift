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
        return view
    }()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addSubview(borderView)
        
        if let collectionViewFlowLayout = collectionViewLayout as? UICollectionViewFlowLayout {
            borderView.frame.size = collectionViewFlowLayout.itemSize
            borderView.layer.cornerRadius = 4
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
