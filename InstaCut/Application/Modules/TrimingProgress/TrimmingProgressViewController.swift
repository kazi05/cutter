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
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var currentPeriodView: UIView!
    
    // MARK: - LifeCycle 🌎
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func actionCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension TrimmingProgressViewController: TrimmingProgressView {
    
}
