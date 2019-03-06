//
//  ViewController.swift
//  InstaCut
//
//  Created by Kazim Gajiev on 15.02.2018.
//  Copyright © 2018 Kazim Gajiev. All rights reserved.
//

import UIKit

protocol MainScreenViewControllerOutput: class {
    func fetchVideos(_ view: UIViewController)
    func gotoCutVideoScreen()
    func passDataToCutVideo(video: VideoModel)
}

protocol MainScreenViewControllerInput: class {
    func displayFetchedVideos(_ videos: [VideoModel])
    func displayAccesError(error: String?)
}

class MainScreenViewController: UIViewController, MainScreenViewControllerInput {
    
    @IBOutlet weak var cameraRollCollectionView: UICollectionView!
    @IBOutlet weak var noItemsView: UIView!
    @IBOutlet weak var noItemsLbl: UILabel!
    @IBOutlet weak var reloadButton: UIButton!
    
    var closure: ((VideoModel) -> Void)?
    
    var videos: [VideoModel] = []
    
    var presenter: MainScreenViewControllerOutput!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        MainScreenAssembly.shared.configure(self)
        self.navigationController?.navigationBar.tintColor = .white
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        performVideos()
    }
    
    //MARK:- Request videos service result from Presenter
    func performVideos() {
        presenter.fetchVideos(self)
    }
    
    //MARK:- Display fethced videos or error
    func displayFetchedVideos(_ videos: [VideoModel]) {
        DispatchQueue.main.async {
            self.cameraRollCollectionView.isHidden = false
            self.noItemsView.isHidden = true
            self.videos.append(contentsOf: videos)
            self.cameraRollCollectionView.reloadData()
        }
    }
    
    //MARK:- Display error view
    func displayAccesError(error: String?) {
        cameraRollCollectionView.isHidden = true
        noItemsView.isHidden = false
        noItemsLbl.text = error
    }
    
    //MARK:- Reload collectionView
    @IBAction func reloadPhotolibraryData(_ sender: Any) {
        performVideos()
    }
    
    //MARK:- Passing data to CutVideo
    func passDataToCutVideo(video: VideoModel) {
        presenter.passDataToCutVideo(video: video)
    }
}

// MARK:- UICollectionViewDataSource
extension MainScreenViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videos.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = cameraRollCollectionView.dequeueReusableCell(withReuseIdentifier: "cameraCell", for: indexPath as IndexPath) as! UserImagesCollectionViewCell
        let video = videos[indexPath.row]
        print(video.asset.duration)
        cell.set(image: video.originalImage, durationText: video.durationTimeString)
        return cell
    }
    
}

//MARK:- CollectionViewDelegate
extension MainScreenViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.presenter.gotoCutVideoScreen()
        closure?(videos[indexPath.row])
    }
    
}

//MARK:- UICollectionViewDelegateFlowLayout
extension MainScreenViewController: UICollectionViewDelegateFlowLayout {
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
}
