//
//  ProgressColorControlView.swift
//  InstaCut
//
//  Created by Kazim Gadjiev on 18.10.2020.
//  Copyright © 2020 Kazim Gajiev. All rights reserved.
//

import UIKit

class ProgressColorControlView: UIView, NibLoadable {
    
    public var tappedOnRemove: ((Bool) -> Void)?
    public var tappedOnChoose: (() -> Void)?

    @IBOutlet weak var cancelOrDeleteButton: UIButton!
    
    private var isRemoving = false
    
    public func setRemoveOrCancelIcon(remove: Bool) {
        if remove {
            isRemoving = true
            cancelOrDeleteButton.setImage(UIImage(named: "delete"), for: .normal)
        }
    }
    
    @IBAction func actionDeleteOrRemoveColor(_ sender: Any) {
        tappedOnRemove?(isRemoving)
    }
    
    @IBAction func actionChooseColor(_ sender: Any) {
        tappedOnChoose?()
    }
}
