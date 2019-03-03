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

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var cameraRollCollectionView: UICollectionView!
    @IBOutlet weak var noItemsView: UIView!
    @IBOutlet weak var noItemsLbl: UILabel!
    @IBOutlet weak var reloadButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkPermission()
    }
    
    func checkPermission() {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized:
            print("Access is granted by user")
            grabVideos()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({
                (newStatus) in
                print("status is \(newStatus)")
                if newStatus ==  PHAuthorizationStatus.authorized {
                    /* do stuff here */
                    print("success")
                    self.grabVideos()
                }
            })
            print("It is not determined until now")
        case .restricted:
            // same same
            print("User do not have access to photo album.")
            self.noItemsView.isHidden = false
            self.reloadButton.isHidden = true
            self.noItemsLbl.text = "Вы не разрешили приложению использовать вашу медиатеку. Для разрешения зайдите в Настройки"
        case .denied:
            // same same
            print("User has denied the permission.")
            self.noItemsView.isHidden = false
            self.reloadButton.isHidden = true
            self.noItemsLbl.text = "Вы не разрешили приложению использовать вашу медиатеку. Для разрешения зайдите в Настройки"
        }
    }
    
    var fetchResult: PHFetchResult<PHAsset>!
    func grabVideos() {
        print("Get video")
        
        let requestOptions = PHVideoRequestOptions()
        requestOptions.version = .original
        requestOptions.deliveryMode = .mediumQualityFormat
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        fetchResult = PHAsset.fetchAssets(with: .video, options: fetchOptions)
        print(fetchResult)
        DispatchQueue.main.async {
            if self.fetchResult.count > 0 {
                self.cameraRollCollectionView.isHidden = false
                self.noItemsView.isHidden = true
                self.cameraRollCollectionView.reloadData()
            }else {
                self.cameraRollCollectionView.isHidden = true
                self.noItemsView.isHidden = false
            }
        }
    }
    
    // MARK:- UICollectionViewData
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if PHPhotoLibrary.authorizationStatus() == .notDetermined {
            return 0
        }else if PHPhotoLibrary.authorizationStatus() == .restricted {
            return 0
        }else if PHPhotoLibrary.authorizationStatus() == .denied {
            return 0
        }
        
        return fetchResult.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = cameraRollCollectionView.dequeueReusableCell(withReuseIdentifier: "cameraCell", for: indexPath as IndexPath) as! UserImagesCollectionViewCell
        cell.userImage.layer.cornerRadius = 3.0
        cell.userImage.clipsToBounds = true
        let asset = fetchResult!.object(at: indexPath.row)
        let width: CGFloat = (self.view.frame.width / 3) - 10
        let height: CGFloat = (self.view.frame.width / 3) - 10
        let size = CGSize(width:width, height:height)
        PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: PHImageContentMode.aspectFill, options: nil) { (image, userInfo) -> Void in
            cell.userImage.image = image
            cell.videoDuration.text = String(format: "%02d:%02d",Int((asset.duration / 60)),Int(asset.duration.rounded()) % 60)
            
        }
        
        return cell
    }
    
    var videoUrl: URL!
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = sb.instantiateViewController(withIdentifier: "CutVideoVC") as! CutVideoVC
        let asset = self.fetchResult!.object(at: indexPath.item)
        vc.videoAsset = asset
        self.navigationController?.pushViewController(vc, animated: true)
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
        checkPermission()
    }
    
}

