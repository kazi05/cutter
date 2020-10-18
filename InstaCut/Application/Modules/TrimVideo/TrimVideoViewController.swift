//
//  TrimVideoViewController.swift
//  InstaCut
//
//  Created by Kazim Gadjiev on 12.10.2020.
//  Copyright © 2020 Kazim Gajiev. All rights reserved.
//

import UIKit
import CoreMedia.CMTime

protocol TrimVideoView: class {
    /// Видео разбилось на периоды
    func periodsCreated()
    
    /// Воспроизвести видео в VideoPreviewView
    func showVideo(_ player: VideoPlayer)
    
    /// Время периода изменилось
    func periodChanged(_ to: Int)
    
    /// Время видео изменилось
    func playerTimeDidChange(_ time: CMTime)
    
    /// Покупка `Убрать маску` куплена
    func hideNoMaskButton()
    
    /// Покупка `Шкала времени` куплена
    func progressBarPurchased(_ colorPicker: ProgressColorPickerController)
    
    func progressColorChanged(_ color: UIColor)
    
    func progressColorChoosed(_ color: UIColor)
    
    func progressColorRemoved()
    
    func progressColorCanceled()
}

class TrimVideoViewController: UIViewController {
    
    // MARK: - Visible properties 👓
    var presenter: TrimVideoPresenter!

    // MARK: - Outlets 🔌
    @IBOutlet weak var videoPreview: VideoPreviewView!
    @IBOutlet weak var collectionView: VideoPeriodsCollectionView!
    @IBOutlet weak var collectionViewRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var noMaskButton: UIButton!
    
    private var colorPickerController: ProgressColorPickerController!
    private var colorPickerControl: ProgressColorControlView!
    private lazy var saveBarButton: UIBarButtonItem = {
        let barButton = UIBarButtonItem(title: .localized("TRIM_VC_SAVE_BUTTON"),
                                        style: .plain,
                                        target: self,
                                        action: #selector(actionSaveVideos(_:)))
        barButton.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.white], for: .normal)
        return barButton
    }()
    
    // MARK: - LifeCycle 🌎
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addRightBarButton()
        configureCollectionView()
        presenter.attachPlayer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        noMaskButton.isHidden = UserDefaults.standard.bool(forKey: IAPProductKind.mask.rawValue)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter.destroyPlayerNow()
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
    
    private func addRightBarButton() {
        navigationItem.rightBarButtonItem = saveBarButton
    }
    
    private func addColorPickerController(_ controller: ProgressColorPickerController) {
        /// Сохраняем ссылки контроллеры, чтобы в дальнейшем удалить их
        self.colorPickerController = controller
        self.colorPickerControl = controller.colorControlView
        
        /// Отодвигаем collectionView влево
        collectionViewRightConstraint.constant = view.bounds.width
        collectionViewLeftConstraint.constant = -view.bounds.width
        
        /// Добавляем контроллер как дочерний контроллер
        addChild(controller)
        controller.view.frame = collectionView.frame
        controller.view.frame.origin.x = view.bounds.width
        
        /// Добавляем управление шкалой вверху экрана
        colorPickerControl.frame = CGRect(x: 0, y: -60, width: view.bounds.width, height: 60)
        view.addSubview(colorPickerControl)
        
        view.addSubview(controller.view)
        controller.didMove(toParent: self)
        
        /// Отключаем кнопку сохранения
        saveBarButton.isEnabled = false
        
        /// У превью видео начинаем анимацию
        videoPreview.showProgressDemostration(true)
        
        UIView.animate(withDuration: 0.4) {
            controller.view.frame.origin.x = 0
            self.colorPickerControl.frame.origin.y = 0
            self.view.layoutIfNeeded()
        }
    }
    
    private func removeColorPickerController() {
        saveBarButton.isEnabled = true
        collectionViewRightConstraint.constant = 0
        collectionViewLeftConstraint.constant = 0
        
        videoPreview.showProgressDemostration(false)
        
        UIView.animate(withDuration: 0.4) {
            self.colorPickerControl.frame.origin.y = -100
            self.colorPickerController.view.frame.origin.x = self.view.bounds.width
            self.view.layoutIfNeeded()
        } completion: { (_) in
            self.colorPickerControl.removeFromSuperview()
            self.colorPickerController.willMove(toParent: nil)
            self.colorPickerController.view.removeFromSuperview()
            self.colorPickerController.removeFromParent()
        }
    }
    
    // MARK: - Actions ⚡️
    @objc
    private func actionSaveVideos(_ sender: UIBarButtonItem) {
        presenter.saveVideos()
    }

    @IBAction func actionPurchaseNoMask(_ sender: Any) {
        presenter.purchaseNoMask()
    }
    
    @IBAction func actionAddProgressBar(_ sender: Any) {
        if let colorPickerController = presenter.showProgressBar() {
            addColorPickerController(colorPickerController)
        }
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
    
    func playerTimeDidChange(_ time: CMTime) {
        videoPreview.playerTimeDidChange(time: time)
    }
    
    func hideNoMaskButton() {
        noMaskButton.isHidden = true
    }
    
    // MARK: - Color picker methods
    func progressBarPurchased(_ colorPicker: ProgressColorPickerController) {
        addColorPickerController(colorPicker)
    }
    
    func progressColorChanged(_ color: UIColor) {
        videoPreview.setProgressColor(color: color)
    }
    
    func progressColorChoosed(_ color: UIColor) {
        removeColorPickerController()
    }
    
    func progressColorRemoved() {
        removeColorPickerController()
    }
    
    func progressColorCanceled() {
        removeColorPickerController()
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
        presenter.seekVideo(at: indexPath.item)
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
