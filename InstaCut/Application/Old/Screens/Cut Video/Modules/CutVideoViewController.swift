//
//  CutVideoViewController.swift
//  InstaCut
//
//  Created by Kazim Gajiev on 04/03/2019.
//  Copyright © 2019 Kazim Gajiev. All rights reserved.
//

import UIKit
import AVFoundation

protocol CutVideoViewControllerInput: class {
    func addPreviewImage(_ image: UIImage)
    func applyPeriodsForVideo(_ periods: [VideoPeriods])
    func passVideoURL(_ videoURL: URL)
}

protocol CutVideoViewControllerOutput: class {
    func saveSelectedVideoModel(_ videoModel: VideoModel)
    func loadImageFromVideo()
    func getPeriodsForVideo()
    func getVideoURL()
    func saveVideosToPhotoAlbum(from videoURL: URL, periods: [VideoPeriods], popUpView: PopUpViewController)
}

class CutVideoViewController: UIViewController, CutVideoViewControllerInput {
    
    @IBOutlet weak var viewPreview: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    
//    @IBOutlet weak var durationTrackView: UIView!
//    @IBOutlet weak var durationTrackSlider: UISlider!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var presenter: CutVideoViewControllerOutput!
    
    var periods = [VideoPeriods]()
    
    var videoURL: URL?
    
    var videoPlayer = VideoPlayerView()
    
    var isPlayed = false
    var isShowed = false
    
    var cellBorder: VideoCellBorder?
    
    private var isCanSave: Bool {
        do {
            let data = try Data(contentsOf: videoURL!)
            let free = DiskStatus.freeDiskSpaceInBytes
            print(free)
            print(Int64(data.count))
            if free < Int64(data.count) {
                return false
            }
        }catch {
            print(error.localizedDescription)
        }
        return true
    }
    
    //MARK:- Configure module
    override func awakeFromNib() {
        super.awakeFromNib()
        CutVideoAssembly.shared.configure(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        presenter.loadImageFromVideo()
        presenter.getPeriodsForVideo()
        presenter.getVideoURL()
    }
    
    //MARK:- Result comes from Presenter
    
    //Apply preview image
    func addPreviewImage(_ image: UIImage) {
        viewPreview.image = image
        imagePreviewTap()
    }
    
    private func imagePreviewTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handlePreviewTap(_:)))
        viewPreview.isUserInteractionEnabled = true
        viewPreview.addGestureRecognizer(tap)
    }
    
    //MARK:- Image tap actions
    @objc private func handlePreviewTap(_ sender: UITapGestureRecognizer) {
        if isPlayed {
            if isShowed {
                hideButton()
            }else {
               self.showButton()
            }
        }
    }
    
    @objc private func hideTimeDurationView() {
        hideButton()
    }
    
    private func showButton() {
        AnimationHelper.animateIn(duration: 0.5) {
            self.playButton.alpha = 1
            self.isShowed = true
            Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.hideTimeDurationView), userInfo: nil, repeats: false)
        }
    }
    
    private func hideButton() {
        if isPlayed {
            AnimationHelper.animateOut(duration: 0.5) {
                self.playButton.alpha = 0
                self.isShowed = false
            }
        }
    }
    
    //MARK:- Configure periods
    //Apply periods of video
    func applyPeriodsForVideo(_ periods: [VideoPeriods]) {
        DispatchQueue.main.async {
            self.periods = periods
            self.collectionView.reloadData()
            self.addCellBorder()
        }
    }
    
    //MARK: - Border cell settings
    private func addCellBorder() {
        let indexPath = IndexPath(item: 0, section: 0)
        let firstCell = createCell(indexPath: indexPath)
        cellBorder = VideoCellBorder(frame: firstCell.frame)
        collectionView.addSubview(cellBorder!)
    }
    
    private func moveCellBorder(to frame: CGRect) {
        let x = frame.origin.x
        let y = frame.origin.y
        AnimationHelper.animateIn(duration: 0.2) {
            self.cellBorder?.frame.origin = CGPoint(x: x, y: y)
        }
    }
    
    private func createCell(indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "videoPreviewCell", for: indexPath)
    }
    
    private func setupBorderCell(indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) ?? collectionView.visibleCells[0]
        moveCellBorder(to: cell.frame)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    //Apply video URL
    var index = 0
    func passVideoURL(_ videoURL: URL) {
        self.videoURL = videoURL        
        videoPlayer = VideoPlayerView(viedoURL: videoURL, previewImage: viewPreview)
        
        let interval = CMTime(seconds: 1, preferredTimescale: 1)
        videoPlayer.player?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { (secondsTime) in
            if self.isPlayed {
                let seconds = CMTimeGetSeconds(secondsTime).rounded()
                let start = self.periods[self.index].start
                if Double(seconds) >= start {
                    let indexPath = IndexPath(item: self.index, section: 0)
                    self.setupBorderCell(indexPath: indexPath)
                    if self.index >= self.periods.count - 1 {
                        self.index = self.periods.count - 1
                    }else {
                        self.index += 1
                    }
                }
            }
        })
        
        viewPreview.layer.addSublayer(videoPlayer.playerLayer)
    }

    //MARK:- Play video button action
    fileprivate func pausingVideo() {
        playButton.setImage(#imageLiteral(resourceName: "play-button.png"), for: .normal)
        videoPlayer.pause()
        isPlayed = false
        isShowed = false
    }
    
    @IBAction func playVideo(_ sender: Any) {
        if !isPlayed {
            isPlayed = true
            self.playButton.alpha = 0
            self.playButton.setImage(UIImage(named: "media-pause") , for: .normal)
            videoPlayer.play()
        }else {
            pausingVideo()
        }
    }
    
    //MARK: - Save button action
    @IBAction func saveVideos(_ sender: Any) {        
        let popUpViewController = PopUpViewController(nibName: "PopUpViewController", bundle: nil)
        popUpViewController.modalPresentationStyle = .overCurrentContext
        popUpViewController.modalTransitionStyle = .crossDissolve
        self.present(popUpViewController, animated: true, completion: nil)
        popUpViewController.showProgressHUD(count: periods.count)
        if let url = videoURL {
            presenter.saveVideosToPhotoAlbum(from: url, periods: self.periods, popUpView: popUpViewController)
        }
    }
    
}

//MARK:- UICollectionViewDataSource
extension CutVideoViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return periods.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "videoPreviewCell", for: indexPath) as! VideoPrevieCell
        
        let period = periods[indexPath.row]
        let startPeriod = period.timeDurationString(time: period.start)
        let endPeriod = period.timeDurationString(time: period.end)
        cell.set(startTime: startPeriod, and: endPeriod)
        cell.set(previewImage: period.previewImage)
        
        return cell
    }
}

//MARK:- UICollectionViewDeleagte
extension CutVideoViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let start = periods[indexPath.row].start
        index = indexPath.row
        let time = CMTime(seconds: start, preferredTimescale: 1000)
        videoPlayer.player?.seek(to: time, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        pausingVideo()
        setupBorderCell(indexPath: indexPath)
        playButton.alpha = 1
    }
}
