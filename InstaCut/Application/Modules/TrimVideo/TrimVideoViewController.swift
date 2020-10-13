//
//  TrimVideoViewController.swift
//  InstaCut
//
//  Created by Kazim Gadjiev on 12.10.2020.
//  Copyright © 2020 Kazim Gajiev. All rights reserved.
//

import UIKit

protocol TrimVideoView: class {
    func periodsCreated()
    func showVideo(_ video: VideoModel)
}

class TrimVideoViewController: UIViewController {
    
    // MARK: - Visible properties 👓
    var presenter: TrimVideoPresenter!

    // MARK: - Outlets 🔌
    @IBOutlet weak var videoPreview: VideoPreviewView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - LifeCycle 🌎
    override func viewDidLoad() {
        super.viewDidLoad()

        configureCollectionView()
    }
    
    // MARK: - Private methods 🕶
    func configureCollectionView() {
        collectionView.register(VideoThumbCollectionViewCell.nib, forCellWithReuseIdentifier: VideoThumbCollectionViewCell.name)
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }

}

// MARK: - View methods
extension TrimVideoViewController: TrimVideoView {
    
    func periodsCreated() {
        activityIndicator.stopAnimating()
        collectionView.reloadData()
    }
    
    func showVideo(_ video: VideoModel) {
        
    }
    
}

// MARK: - Collection view delegate/dataSource methods
extension TrimVideoViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        presenter.getPeriodsCount()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoThumbCollectionViewCell.name, for: indexPath) as? VideoThumbCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let period = presenter.getPreiod(at: indexPath.item)
        cell.configure(with: period)
        
        return cell
    }
    
    // MARK: - Flow layout methods
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.bounds.height - collectionView.bounds.height / 3
        
        return CGSize(width: height, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
}
