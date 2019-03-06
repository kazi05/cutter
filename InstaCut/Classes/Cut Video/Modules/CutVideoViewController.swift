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
}

protocol CutVideoViewControllerOutput: class {
    func saveSelectedVideoModel(_ videoModel: VideoModel)
    func loadImageFromVideo()
}

class CutVideoViewController: UIViewController, CutVideoViewControllerInput {
    
    @IBOutlet weak var viewPreview: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    
//    @IBOutlet weak var durationTrackView: UIView!
//    @IBOutlet weak var durationTrackSlider: UISlider!
    
//    @IBOutlet weak var collectionView: UICollectionView!
    
    var presenter: CutVideoViewControllerOutput!
    
    var periods = [[String: Any]]()
    
    //MARK:- Configure module
    override func awakeFromNib() {
        super.awakeFromNib()
        CutVideoAssembly.shared.configure(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        presenter.loadImageFromVideo()
    }
    
    //MARK:- Result comes from Presenter
    func addPreviewImage(_ image: UIImage) {
        self.viewPreview.image = image
    }

}
