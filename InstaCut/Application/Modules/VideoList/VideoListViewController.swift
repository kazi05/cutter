//
//  VideoListViewController.swift
//  InstaCut
//
//  Created by Kazim Gadjiev on 12.10.2020.
//  Copyright © 2020 Kazim Gajiev. All rights reserved.
//

import UIKit

protocol VideoListView: class {
    
}

class VideoListViewController: UIViewController {
    
    // MARK: - Visible properties 👓
    var presenter: VideoListPresenter!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}

extension VideoListViewController: VideoListView {
    
}
