//
//  ProgressColorPickerController.swift
//  InstaCut
//
//  Created by Kazim Gadjiev on 18.10.2020.
//  Copyright © 2020 Kazim Gajiev. All rights reserved.
//

import UIKit

protocol ProgressColorPickerView: class {
    func setSelectedColor(color: UIColor?)
}

class ProgressColorPickerController: UIViewController {
    
    // MARK: - Visible properties 👓
    var presenter: ProgressColorPickerPresenter!

    // MARK: - Outlets 🔌
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var selectedColorView: UIView!
    
    private(set) var colorControlView = ProgressColorControlView.loadFromNib()
    
    private let defaultColors: [UIColor] = [
        UIColor(named: "appMainColor")!,
        .black,
        .white,
        .systemRed,
        .systemGreen,
        .systemBlue,
        .systemTeal,
        .clear
    ]
    
    // MARK: - LifeCycle 🌎
    override func viewDidLoad() {
        super.viewDidLoad()

        configureCollectionView()
        observeControl()
        presenter.viewDidLoad()
    }
    
    // MARK: - Private methods 🕶
    private func configureCollectionView() {
        collectionView.register(ColorPickerCollectionViewCell.nib, forCellWithReuseIdentifier: ColorPickerCollectionViewCell.name)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
    }
    
    private func observeControl() {
        colorControlView.tappedOnChoose = { [weak self] in
            self?.presenter.colorChoosed()
        }
        
        colorControlView.tappedOnRemove = { [weak self] removed in
            if removed {
                self?.presenter.colorRemoved()
            } else {
                self?.presenter.cancelPicker()
            }
        }
    }
}

// MARK: - Collection view delegate/dataSource methods
extension ProgressColorPickerController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        defaultColors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorPickerCollectionViewCell.name, for: indexPath) as? ColorPickerCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let color = defaultColors[indexPath.item]
        cell.setColor(color: color, isLastCell: indexPath.item == defaultColors.count - 1)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    // MARK: - Flow layout methods
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.bounds.height - 20
        
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


// MARK: - View methods
extension ProgressColorPickerController: ProgressColorPickerView {
    
    func setSelectedColor(color: UIColor?) {
        if let color = color {
            if let colorIndex = defaultColors.firstIndex(of: color) {
                collectionView.selectItem(at: IndexPath(item: colorIndex, section: 0), animated: false, scrollPosition: .left)
            } else {
                selectedColorView.backgroundColor = color
                colorControlView.setRemoveOrCancelIcon(remove: true)
            }
        } else {
            collectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: .left)
            presenter.changeColor(color: defaultColors[0])
        }
    }
    
}
