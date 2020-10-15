//
//  TriminProgressViewController.swift
//  InstaCut
//
//  Created by Kazim Gadjiev on 14.10.2020.
//  Copyright © 2020 Kazim Gajiev. All rights reserved.
//

import UIKit

protocol TrimmingProgressView: class {
    func period(at index: Int, progress: Float)
    func periodCompleted(at index: Int)
    func renderingCompleted()
}

class TrimmingProgressViewController: UIViewController {
    
    // MARK: - Visible properties 👓
    var presenter: TrimmingProgressPresenter!
    
    // MARK: - Private properties 🕶
    private var cellIdentity: CGRect = .zero

    // MARK: - Outlets 🔌
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var currentPeriodView: UIView!
    @IBOutlet weak var finishLabel: UILabel!
    
    // MARK: - LifeCycle 🌎
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let firstCell = collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) else { return }
        
        cellIdentity = firstCell.frame
        
        UIView.animate(withDuration: 0.3) {
            firstCell.frame = self.currentPeriodView.frame.offsetBy(dx: self.collectionView.contentOffset.x - 30, dy: -30)
        } completion: { _ in
            self.presenter.beginRendering()
        }
    }
    
    // MARK: - Private methods 🕶
    private func configureCollectionView() {
        collectionView.register(VideoTrimmingCollectionViewCell.nib, forCellWithReuseIdentifier: VideoTrimmingCollectionViewCell.name)
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    // MARK: - Actions ⚡️
    @IBAction func actionCancel(_ sender: Any) {
        presenter.cancelRendering()
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - View methods
extension TrimmingProgressViewController: TrimmingProgressView {
    
    func period(at index: Int, progress: Float) {
        guard let periodCell = getCell(by: index) else { return }
        periodCell.progressChanged(progress)
    }
    
    func periodCompleted(at index: Int) {
        guard let periodCell = getCell(by: index),
              let lastCell = collectionView.visibleCells.last,
              let indexPath = collectionView.indexPath(for: lastCell)
        else { return }
        
        if index == indexPath.item - 1 && presenter.getPeriodsCount() > indexPath.item {
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
            
        periodCell.progressCompleted()
        UIView.animate(withDuration: 0.3) {
            periodCell.frame = self.cellIdentity
        } completion: { (_) in
            guard let nextCell = self.getCell(by: index + 1) else { return }
            
            self.cellIdentity = nextCell.frame
            
            UIView.animate(withDuration: 0.3) {
                nextCell.frame = self.currentPeriodView.frame.offsetBy(dx: self.collectionView.contentOffset.x - 30, dy: -30)
            }
        }
        
    }
    
    func renderingCompleted() {
        if let lastCell = collectionView.cellForItem(at: IndexPath(item: presenter.getPeriodsCount() - 1, section: 0)) as? VideoTrimmingCollectionViewCell {
            lastCell.progressCompleted()
            UIView.animate(withDuration: 0.3) {
                lastCell.frame = self.cellIdentity
            }
        }
        
        currentPeriodView.isHidden = true
        finishLabel.isHidden = false
        print("[View] Rendering complete")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    private func getCell(by index: Int) -> VideoTrimmingCollectionViewCell? {
        return collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? VideoTrimmingCollectionViewCell
    }
}

// MARK: - Collection view dataSource methods
extension TrimmingProgressViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.getPeriodsCount()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoTrimmingCollectionViewCell.name, for: indexPath) as? VideoTrimmingCollectionViewCell else { return UICollectionViewCell() }
        
        let period = presenter.getPreiod(at: indexPath.item)
        cell.configure(with: period.previewImage, completed: presenter.isPeriodCompleted(at: indexPath.item))
        
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
