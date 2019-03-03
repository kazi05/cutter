//
//  ViewController.swift
//  InstaCut
//
//  Created by Kazim Gajiev on 15.02.2018.
//  Copyright © 2018 Kazim Gajiev. All rights reserved.
//

import UIKit
import Photos
import MobileCoreServices

let sb = UIStoryboard(name: "Main", bundle: nil)

protocol MainScreenViewControllerOutput {
    func fetchVideos(_ view: UIViewController)
}

class MainScreenViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var cameraRollCollectionView: UICollectionView!
    @IBOutlet weak var noItemsView: UIView!
    @IBOutlet weak var noItemsLbl: UILabel!
    @IBOutlet weak var reloadButton: UIButton!
    
    var videos: [VideoModel] = []
    
    var presenter: MainScreenViewControllerOutput!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        MainScreenAssembly.shared.configure(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        performVideos()
    }
    
    func performVideos() {
        presenter.fetchVideos(self)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (self.view.frame.width / 3) - 10
        
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 6
    }
    
    
    @IBAction func reloadPhotolibraryData(_ sender: Any) {
        performVideos()
    }
    
}

// MARK:- UICollectionViewDataSource
extension MainScreenViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videos.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = cameraRollCollectionView.dequeueReusableCell(withReuseIdentifier: "cameraCell", for: indexPath as IndexPath) as! UserImagesCollectionViewCell
        cell.userImage.layer.cornerRadius = 3.0
        cell.userImage.clipsToBounds = true
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}
