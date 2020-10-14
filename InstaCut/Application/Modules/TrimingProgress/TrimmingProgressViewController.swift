//
//  TriminProgressViewController.swift
//  InstaCut
//
//  Created by Kazim Gadjiev on 14.10.2020.
//  Copyright © 2020 Kazim Gajiev. All rights reserved.
//

import UIKit

protocol TrimmingProgressView: class {
    
}

class TrimmingProgressViewController: UIViewController {
    
    // MARK: - Visible properties 👓
    var presenter: TrimmingProgressPresenter!

    // MARK: - Outlets 🔌
    
    // MARK: - LifeCycle 🌎
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}

extension TrimmingProgressViewController: TrimmingProgressView {
    
}
