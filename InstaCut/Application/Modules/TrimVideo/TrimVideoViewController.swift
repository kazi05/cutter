//
//  TrimVideoViewController.swift
//  InstaCut
//
//  Created by Kazim Gadjiev on 12.10.2020.
//  Copyright © 2020 Kazim Gajiev. All rights reserved.
//

import UIKit

protocol TrimVideoView: class {
    /// Видео разбилось на периоды
    func periodsCreated()
    
    /// Воспроизвести видео в VideoPreviewView
    func showVideo(_ player: VideoPlayer)
    
    /// Время периода изменилось
    func periodChanged(_ to: Int)
}

class TrimVideoViewController: UIViewController {
    
    // MARK: - Visible properties 👓
    var presenter: TrimVideoPresenter!

    // MARK: - Outlets 🔌
    @IBOutlet weak var videoPreview: VideoPreviewView!
    @IBOutlet weak var collectionView: VideoPeriodsCollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - LifeCycle 🌎
    override func viewDidLoad() {
        super.viewDidLoad()

        configureCollectionView()
        presenter.attachPlayer()
    }
    
    // MARK: - Private methods 🕶
    private func configureCollectionView() {
        collectionView.register(VideoThumbCollectionViewCell.nib, forCellWithReuseIdentifier: VideoThumbCollectionViewCell.name)
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func moveBorder(at index: Int) {
        guard let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) else { return }
        self.collectionView.moveBorderView(to: cell.center)
    }

}

// MARK: - View methods
extension TrimVideoViewController: TrimVideoView {
    
    func periodsCreated() {
        activityIndicator.stopAnimating()
        collectionView.reloadData()
        
        DispatchQueue.main.async {
            guard let firstCell = self.collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) else { return }
            self.collectionView.moveBorderView(to: firstCell.center, animated: false)
        }
    }
    
    func showVideo(_ player: VideoPlayer) {
        videoPreview.attach(videoPlayer: player)
    }
    
    func periodChanged(_ to: Int) {
        moveBorder(at: to)
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        moveBorder(at: indexPath.item)
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
