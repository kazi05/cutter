//
//  CutVideoViewController.swift
//  InstaCut
//
//  Created by Kazim Gajiev on 04/03/2019.
//  Copyright © 2019 Kazim Gajiev. All rights reserved.
//

import UIKit

protocol CutVideoViewControllerInput: class {
    func addPreviewImage(_ image: UIImage)
    func applyPeriodsForVideo(_ periods: [VideoPeriods])
}

protocol CutVideoViewControllerOutput: class {
    func saveSelectedVideoModel(_ videoModel: VideoModel)
    func loadImageFromVideo()
    func getPeriodsForVideo()
}

class CutVideoViewController: UIViewController, CutVideoViewControllerInput {
    
    @IBOutlet weak var viewPreview: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    
//    @IBOutlet weak var durationTrackView: UIView!
//    @IBOutlet weak var durationTrackSlider: UISlider!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var presenter: CutVideoViewControllerOutput!
    
    var periods = [VideoPeriods]()
    
    //MARK:- Configure module
    override func awakeFromNib() {
        super.awakeFromNib()
        CutVideoAssembly.shared.configure(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        presenter.loadImageFromVideo()
        presenter.getPeriodsForVideo()
    }
    
    //MARK:- Result comes from Presenter
    func addPreviewImage(_ image: UIImage) {
        self.viewPreview.image = image
    }
    
    func applyPeriodsForVideo(_ periods: [VideoPeriods]) {
        DispatchQueue.main.async {
            self.periods = periods
            self.collectionView.reloadData()
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
    
}