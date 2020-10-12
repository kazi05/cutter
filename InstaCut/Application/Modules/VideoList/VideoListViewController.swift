//
//  VideoListViewController.swift
//  InstaCut
//
//  Created by Kazim Gadjiev on 12.10.2020.
//  Copyright © 2020 Kazim Gajiev. All rights reserved.
//

import UIKit

protocol VideoListView: class {
    func loadVideosError(_ error: String)
}

class VideoListViewController: UIViewController {
    
    // MARK: - Visible properties 👓
    var presenter: VideoListPresenter!

    override func viewDidLoad() {
        super.viewDidLoad()

        presenter.loadVideos()
    }

}

extension VideoListViewController: VideoListView {
    
    func loadVideosError(_ error: String) {
        print(error)
    }
    
}
