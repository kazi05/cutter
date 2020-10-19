//
//  VideoListViewController.swift
//  InstaCut
//
//  Created by Kazim Gadjiev on 12.10.2020.
//  Copyright © 2020 Kazim Gajiev. All rights reserved.
//

import UIKit

protocol VideoListView: class {
    func loadVideosCompleted()
    func loadVideosError(_ error: Error)
}

class VideoListViewController: UIViewController {
    
    // MARK: - Visible properties 👓
    var presenter: VideoListPresenter!

    // MARK: - Outlets 🔌
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    
    // MARK: - LifeCycle 🌎
    override func viewDidLoad() {
        super.viewDidLoad()
        title = .localized("VIDEO_LIST_TITLE")
        
        configureCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.loadVideos()
    }
    
    // MARK: - Private methods 🕶
    func configureCollectionView() {
        collectionView.register(VideoThumbCollectionViewCell.nib, forCellWithReuseIdentifier: VideoThumbCollectionViewCell.name)
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    // MARK: - Actions ⚡️
    @IBAction func actionReloadLibrary(_ sender: Any) {
        presenter.loadVideos()
    }
}

// MARK: - View methods
extension VideoListViewController: VideoListView {
    
    func loadVideosCompleted() {
        errorView.isHidden = true
        collectionView.isHidden = false
        collectionView.reloadData()
    }
    
    func loadVideosError(_ error: Error) {
        errorView.isHidden = false
        collectionView.isHidden = true
        errorLabel.text = error.localizedDescription
    }
    
}

// MARK: - Collection view methods
extension VideoListViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.getVideosCount()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoThumbCollectionViewCell.name, for: indexPath) as? VideoThumbCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let video = presenter.getVideo(at: indexPath.item)
        cell.configure(with: video)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter.presentTrimmerView(by: indexPath.item)
    }
    
    // MARK: - Flow layout methods
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width / 3 - 4
        
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 2, bottom: 5, right: 2)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
}
