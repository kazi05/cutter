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
        configureCollectionView()
    }
    
    // MARK: - Private methods 🕶
    private func configureCollectionView() {
        collectionView.register(VideoTrimmingCollectionViewCell.nib, forCellWithReuseIdentifier: VideoTrimmingCollectionViewCell.name)
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    // MARK: - Actions ⚡️
    @IBAction func actionCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - View methods
extension TrimmingProgressViewController: TrimmingProgressView {
    
}

// MARK: - Collection view dataSource methods
extension TrimmingProgressViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.getPeriodsCount()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoTrimmingCollectionViewCell.name, for: indexPath) as? VideoTrimmingCollectionViewCell else { return UICollectionViewCell() }
        
        let period = presenter.getPreiod(at: indexPath.item)
        cell.configure(with: period.previewImage)
        
        return cell
    }
    
    // MARK: - Flow layout methods
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.bounds.height - 10
        
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
