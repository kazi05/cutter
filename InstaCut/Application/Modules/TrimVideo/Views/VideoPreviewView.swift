//
//  VideoPreviewView.swift
//  InstaCut
//
//  Created by Kazim Gadjiev on 13.10.2020.
//  Copyright © 2020 Kazim Gajiev. All rights reserved.
//

import UIKit

class VideoPreviewView: UIView {
    
    var contenView: UIView?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        guard let view = loadViewFromNib() else { return }
        view.frame = self.bounds
        self.addSubview(view)
        contenView = view
    }
    
    private func loadViewFromNib() -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
}
