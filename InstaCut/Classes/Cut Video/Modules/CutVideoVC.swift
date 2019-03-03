//
//  CutVideoVC.swift
//  InstaCut
//
//  Created by Kazim Gajiev on 15.02.2018.
//  Copyright © 2018 Kazim Gajiev. All rights reserved.
//

import UIKit
import Photos
import Segmentio
import JGProgressHUD
import MobileCoreServices
import StoreKit

var iCloudKeyStore: NSUbiquitousKeyValueStore? = NSUbiquitousKeyValueStore()
let iCloudTextKey = "ProVersionAviable"
var isProVersion = false
var isGetedProduct = false

class CutVideoVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var viewPreview: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    
    @IBOutlet weak var segmentedControll: Segmentio!
    
    @IBOutlet weak var durationTrackView: UIView!
    @IBOutlet weak var durationTrackSlider: UISlider!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var periods = [[String: Any]]()
    
    var videoUrl: URL!
    
    var videoAsset: PHAsset!
    
    var isCanSave = true
    
    fileprivate func setUpPHAssetInfo() {
        let options: PHVideoRequestOptions = PHVideoRequestOptions()
        options.version = .original
        PHImageManager.default().requestAVAsset(forVideo: videoAsset, options: options, resultHandler: {(asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) -> Void in
            if let urlAsset = asset as? AVURLAsset {
                let localVideoUrl: URL = urlAsset.url as URL
                DispatchQueue.main.async {
                    self.viewPreview.image = self.thumbnailImage(asset: localVideoUrl, start: 1)
                    self.videoUrl = localVideoUrl
                    self.delegateVideoToPeriods(videoUrl: localVideoUrl)
                    self.player = AVPlayer(url: localVideoUrl)
                    do {
                        let data = try Data(contentsOf: localVideoUrl)
                        let free = DiskStatus.freeDiskSpaceInBytes
                        if free < Int64(data.count) {
                            self.isCanSave = false
                        }
                    }catch {
                        print("Get video error: \(error.localizedDescription)")
                    }
                }
            }
//            DispatchQueue.main.async {
//                self.sliderSettings(with: (asset?.duration)!)
//            }
        })
    }
    
    @objc func setupNavigationCustomBar() {
        let image = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        image.image = #imageLiteral(resourceName: "Cutter-Pro-Mask")
        image.contentMode = .scaleAspectFit
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        view.addSubview(image)
        let tap = UITapGestureRecognizer(target: self, action: #selector(showProVersionView))
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tap)
        self.navigationItem.titleView = view
    }
    
    @objc func showProVersionView() {
        animateIn(proVersionView: proVersionView, cancelButton: cancelButton) {
            self.proVersionView.addSubview(self.buyBButton)
            self.proVersionView.addSubview(self.screenshotImage)
            self.proVersionView.addSubview(self.titleLabel)
            self.proVersionView.addSubview(self.descrLabel)
            if #available(iOS 9.0, *) {
                self.proVersionView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 50).isActive = true
                self.proVersionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -100).isActive = true
                self.proVersionView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 50).isActive = true
                self.proVersionView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -50).isActive = true
                
                self.screenshotImage.topAnchor.constraint(equalTo: self.proVersionView.topAnchor, constant: 0).isActive = true
                self.screenshotImage.leftAnchor.constraint(equalTo: self.proVersionView.leftAnchor, constant: 0).isActive = true
                self.screenshotImage.rightAnchor.constraint(equalTo: self.proVersionView.rightAnchor, constant: 0).isActive = true
                self.screenshotImage.heightAnchor.constraint(equalToConstant: (self.view.frame.height - 100) - 200).isActive = true
                
                self.titleLabel.leftAnchor.constraint(equalTo: self.proVersionView.leftAnchor, constant: 20).isActive = true
                self.titleLabel.rightAnchor.constraint(equalTo: self.proVersionView.rightAnchor, constant: -20).isActive = true
                self.titleLabel.topAnchor.constraint(equalTo: self.screenshotImage.bottomAnchor, constant: 10).isActive = true
                
                self.descrLabel.leftAnchor.constraint(equalTo: self.proVersionView.leftAnchor, constant: 20).isActive = true
                self.descrLabel.rightAnchor.constraint(equalTo: self.proVersionView.rightAnchor, constant: -20).isActive = true
                self.descrLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 10).isActive = true
                
                self.buyBButton.leftAnchor.constraint(equalTo: self.proVersionView.leftAnchor, constant: 0).isActive = true
                self.buyBButton.rightAnchor.constraint(equalTo: self.proVersionView.rightAnchor, constant: 0).isActive = true
                self.buyBButton.bottomAnchor.constraint(equalTo: self.proVersionView.bottomAnchor, constant: 0).isActive = true
                self.buyBButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
            }
        }
    }
    
    lazy var cancelButton: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 25, y: 35, width: 80, height: 25)
        button.contentHorizontalAlignment = .left
        button.setImage(#imageLiteral(resourceName: "letter-x"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(hideProVersionView), for: .touchUpInside)
        return button
    }()
    
    lazy var proVersionView: UIView = {
//        let proView = UIView(frame: CGRect(x: (self.view.frame.width / 2) - ((self.view.frame.width - 100) / 2) , y: self.view.frame.height, width: self.view.frame.width - 100, height: self.view.frame.height - 100))
        let proView = UIView()
        proView.alpha = 0
        proView.backgroundColor = UIColor(red: 41/255.0, green: 38/255.0, blue: 38/255.0, alpha: 1.0)
        proView.layer.cornerRadius = 10
        proView.clipsToBounds = true
        proView.translatesAutoresizingMaskIntoConstraints = false
        return proView
    }()
    
    lazy var screenshotImage: UIImageView = {
//        let imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: proVersionView.frame.width, height: proVersionView.frame.height - 200))
        let imgView = UIImageView()
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.image = #imageLiteral(resourceName: "proversionscreenshot")
//        imgView.contentMode = .scaleAspectFit
        return imgView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = product.localizedTitle
        label.textColor = .lightGray
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var descrLabel: UILabel = {
        let label = UILabel()
        label.text = product.localizedDescription
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private func priceString() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = product.priceLocale
        
        return numberFormatter.string(from: product.price)!
    }
    
    lazy var buyBButton: UIButton = {
        let button = UIButton(type: UIButtonType.system)
        let buyTitle = NSLocalizedString("BUY", comment: "")
        button.setTitle("\(buyTitle) - \(priceString())", for: .normal)
        let font = UIFont(name: "AvenirNext-DemiBold", size: 17)
        button.titleLabel?.textColor = UIColor.white
        button.titleLabel?.font = font
//        button.frame = CGRect(x: 0, y: proVersionView.frame.height - 50, width: proVersionView.frame.width, height: 50)
        button.tintColor = .white
        button.backgroundColor = UIColor(red: 215/255.0, green: 71/255.0, blue: 14/255.0, alpha: 1.0)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(buyProVersion), for: .touchUpInside)
        return button
    }()
    
    @objc func buyProVersion() {
        proVersionView.removeFromSuperview()
        cancelButton.removeFromSuperview()
        hud.textLabel.text = ""
        hud.show(in: self.keyWindow!)
        IAPManager.shared.purchase()
    }
    
    func saveToiCloud() {
        iCloudKeyStore?.set(true, forKey: iCloudTextKey)
        iCloudKeyStore?.synchronize()
        UserDefaults.standard.set(true, forKey: iCloudTextKey)
        UserDefaults.standard.synchronize()
    }
    
    @objc func hideProVersionView() {
        animateOut(proVersionView: proVersionView, cancelButton: cancelButton) {
            //
        }
    }
    
    fileprivate func configurationSetup() {
        if !isProVersion && isGetedProduct {
            setupNavigationCustomBar()
        }
        setUpPHAssetInfo()
        setupSegmentedControll()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configurationSetup()
        
        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateSlider), userInfo: nil, repeats: true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(purchaseFailed), name: NSNotification.Name("paymentFailed"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(purchasePurchased), name: NSNotification.Name("paymentPurchased"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(purchaseCanceled), name: NSNotification.Name("paymentCanceled"), object: nil)
        if !isProVersion {
            NotificationCenter.default.addObserver(self, selector: #selector(setupNavigationCustomBar), name: NSNotification.Name("producrGeted"), object: nil)
        }
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func purchaseFailed() {
        print("Failed")
        DispatchQueue.main.async {
            self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
            let errorTitle = NSLocalizedString("FAILED", comment: "")
            self.hud.textLabel.text = errorTitle
            self.hud.detailTextLabel.isHidden = true
            self.hud.indicatorView?.tintColor = .red
            self.hud.dismiss(afterDelay: 2.0, animated: true)
            self.animateOut(proVersionView: nil, cancelButton: nil) {
                self.hud.indicatorView = JGProgressHUDIndeterminateIndicatorView()
                self.hud.textLabel.text = "\(self.waitTitle) ..."
            }
        }
    }
    
    @objc func purchaseCanceled() {
        print("Canceled")
        DispatchQueue.main.async {
            self.hud.dismiss(afterDelay: 2.0, animated: true)
            self.animateOut(proVersionView: nil, cancelButton: nil) {
                self.hud.textLabel.text = "\(self.waitTitle) ..."
            }
        }
    }
    
    @objc func purchasePurchased() {
        print("Succes")
        DispatchQueue.main.async {
            self.saveToiCloud()
            self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
            let succesTitle = NSLocalizedString("SUCCES", comment: "")
            self.hud.textLabel.text = succesTitle
            self.hud.detailTextLabel.isHidden = true
            self.hud.indicatorView?.tintColor = UIColor(red:0.36, green:0.80, blue:0.68, alpha:1.0)
            self.hud.dismiss(afterDelay: 2.0, animated: true)
            self.animateOut(proVersionView: nil, cancelButton: nil) {
                self.hud.indicatorView = JGProgressHUDIndeterminateIndicatorView()
                self.hud.textLabel.text = "\(self.waitTitle) ..."
                self.configurationSetup()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let firstIndex = IndexPath(item: 0, section: 0)
        let cell = collectionView.cellForItem(at: firstIndex) as! VideoPrevieCell
        cell.isSelected = true
        collectionView.selectItem(at: firstIndex, animated: false, scrollPosition: .left)
        selectCells.append(cell)
//        selectedCell.append(firstIndex)
    }
    
    //MARK: Установка бара
    func setupSegmentedControll() {
        var bgColor: UIColor!
        var appColor: UIColor!
        if #available(iOS 11.0, *) {
            bgColor = UIColor(named: "bgColor")!
            appColor = UIColor(named: "appMainColor")!
        } else {
            bgColor = UIColor(red: 30/255.0, green: 30/255.0, blue: 30/255.0, alpha: 1.0)
            appColor = UIColor(red: 215/255.0, green: 71/255.0, blue: 14/255.0, alpha: 1.0)
        }
        let indicatorOptions = SegmentioIndicatorOptions(type: .bottom, ratio: 1, height: 4, color:  appColor)
        let state = SegmentioState(backgroundColor: bgColor, titleFont: UIFont(name: "AvenirNext-Medium", size: 17)!, titleTextColor: .white)
        let states = SegmentioStates(
            defaultState: state,
            selectedState: state,
            highlightedState: state
        )
        
        let horizontalSeparator = SegmentioHorizontalSeparatorOptions(type: .topAndBottom, height: 0, color: .clear)
        let verticalSeparator = SegmentioVerticalSeparatorOptions(ratio: 0, color: .clear)
        let options = SegmentioOptions(backgroundColor: bgColor, segmentPosition: .fixed(maxVisibleItems: 2), scrollEnabled: false, indicatorOptions: indicatorOptions, horizontalSeparatorOptions: horizontalSeparator, verticalSeparatorOptions: verticalSeparator, imageContentMode: .center, labelTextAlignment: .center, labelTextNumberOfLines: 1, segmentStates: states , animationDuration: CFTimeInterval(exactly: 0.1)!)
        
        var content = [SegmentioItem]()
        let propal = SegmentioItem(title: NSLocalizedString("POST", comment: ""), image: nil)
        let find = SegmentioItem(title: NSLocalizedString("STORIES", comment: ""), image: nil)
        content.append(propal)
        content.append(find)
        segmentedControll.setup(content: content, style: SegmentioStyle.onlyLabel, options: options)
        segmentedControll.selectedSegmentioIndex = 0
        
        segmentedControll.valueDidChange = { segmentio, segmnetIndex in
            self.delegateVideoToPeriods(videoUrl: self.videoUrl)
           self.removeBordersFromCells()
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(showDurationTrackView))
        viewPreview.addGestureRecognizer(tap)
        createGradientLayer()
        
    }
    
    //MARK: Блок с трек линией
    func createGradientLayer() {
        let gradientLayer = CAGradientLayer()
        
        gradientLayer.frame = self.durationTrackView.bounds
        
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        
        self.durationTrackView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    var trackListMarks = [UIView]()
    func sliderSettings(with duration: CMTime) {
        for exist in trackListMarks {
            exist.removeFromSuperview()
        }
        trackListMarks = []
        durationTrackSlider.setThumbImage(#imageLiteral(resourceName: "track-ball"), for: .normal)
//        durationTrackSlider.setMaximumTrackImage(#imageLiteral(resourceName: "track-thickness"), for: .normal)
//        durationTrackSlider.setMinimumTrackImage(#imageLiteral(resourceName: "track-thickness"), for: .normal)
        durationTrackSlider.minimumValue = 0
        
        let duration : CMTime = duration
        let seconds : Float64 = CMTimeGetSeconds(duration)
        
        durationTrackSlider.maximumValue = Float(seconds)
        durationTrackSlider.isContinuous = true
        
        let size: CGFloat = periods.count <= 10 ? 8 : 4
        for i in 1..<periods.count {
            let xPos = CGFloat(i) * (durationTrackSlider.frame.width / CGFloat(periods.count))
            let tick = UIView(frame: CGRect(x: xPos.rounded() + 3, y: periods.count <= 10 ? 4 : 6, width: size, height: size))
            tick.backgroundColor = UIColor(red: 122/255.0, green: 122/255.0, blue: 123/255.0, alpha: 1.0)
            tick.layer.cornerRadius = size / 2
            tick.tag = i
            trackListMarks.append(tick)
        }
        
        for view in trackListMarks {
            durationTrackSlider.insertSubview(view, belowSubview: durationTrackSlider)
        }
        
        durationTrackSlider.addTarget(self, action: #selector(playbackSliderValueChanged(_:)), for: .valueChanged)
    }

    var index = 0
    @objc func playbackSliderValueChanged(_ playbackSlider:UISlider) {
        let currentTime = Int(playbackSlider.value.rounded())
        for (markIndex, period) in periods.enumerated() {
            let start = period["start"] as? Int
            if currentTime > start! {
                index = markIndex
                for i in 0..<markIndex {
                    durationTrackSlider.viewWithTag(i + 1)?.backgroundColor = UIColor(red: 215/255.0, green: 71/255.0, blue: 14/255.0, alpha: 1.0)
                }
            }
            durationTrackSlider.viewWithTag(markIndex + 1)?.backgroundColor = UIColor(red: 122/255.0, green: 122/255.0, blue: 123/255.0, alpha: 1.0)
        }
        
        let seconds : Int64 = Int64(playbackSlider.value)
        let targetTime:CMTime = CMTimeMake(seconds, 1)
        
        player.seek(to: targetTime)
        
        if player.rate == 0
        {
            player.play()
        }
    }
    
    @objc func updateSlider() {
        if player.rate != 0 {
            let currentTime = Float(CMTimeGetSeconds( player.currentTime()))
            let start = periods[index]["start"] as? Int
            if Int(currentTime.rounded()) > start! {
                durationTrackSlider.viewWithTag(index+1)?.backgroundColor = UIColor(red: 215/255.0, green: 71/255.0, blue: 14/255.0, alpha: 1.0)
                let indexPath = IndexPath(item: index, section: 0)
                collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
                if index >= periods.count - 1 {
                    print("More then count")
                    index = periods.count - 1
                }else {
                    index += 1
                }
            }
            durationTrackSlider.value = Float(CMTimeGetSeconds( player.currentTime()))
        }
    }
    
    //MARK: Разбиение видео на периоды
    func delegateVideoToPeriods(videoUrl: URL) {
        self.periods = []
        let asset = AVAsset(url: videoUrl)
        let length = Double(asset.duration.value) / Double(asset.duration.timescale)
        let rounded: Double = length.rounded()
        var loop = 1
        var start = 0
        var end = 0
        let time = segmentedControll.selectedSegmentioIndex == 0 ? 60 : 15
        for index in 1...Int(rounded) {
            if index % (time * loop) == 0  {
                if index == time {
                    start = 0
                    end = time * loop
                }else {
                    start = time * (loop - 1)
                    end = time * (loop)
                }
                loop += 1
                let element = ["start": start, "end": end]
                periods.append(element)
            }
        }
        if Int(rounded) % (time * loop) > 0 {
            start = time * (loop - 1)
            end = Int(rounded)
            let element = ["start": start, "end": end]
            periods.append(element)
        }
        
        self.collectionView.reloadData()
        self.sliderSettings(with: asset.duration)
    }
    
    //MARK: Выборка изображения из видео
    func thumbnailImage(asset: URL, start: Int) -> UIImage? {
        let asset = AVAsset(url: asset)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            let tumbnailCGIImage = try imageGenerator.copyCGImage(at: CMTime(seconds: Double(start), preferredTimescale: 1000), actualTime: nil)
            if isProVersion {
                return UIImage(cgImage: tumbnailCGIImage)
            }else {
                let maskImage = UIImage(cgImage: tumbnailCGIImage).addText()
                return maskImage
            }
        }catch {
            print(error)
        }
        
        return nil
    }
    
    //MARK: AVPlayer creation
    var player: AVPlayer!
    
    lazy var playerLayer: AVPlayerLayer = {
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = viewPreview.calculateRectOfImageInImageView()
        if !isProVersion {
            let imageWidth = playerLayer.frame.width
            let imageHeight = playerLayer.frame.height
            let sizeConst: CGFloat = imageHeight > imageWidth ? 12 : 5
            let sizeHeight = imageHeight / sizeConst
            print("Image x: \(imageWidth - (sizeHeight * 1.3)) \nImage y: \(imageHeight + (sizeHeight * 1.3))")
            var overlayLayer = CALayer()
            let textImage = UIImage(named: "Cutter-maska")
            overlayLayer.contents = textImage?.cgImage
            overlayLayer.frame = CGRect(x: imageWidth - (sizeHeight * 1.3), y: imageHeight - (sizeHeight * 1.3), width: sizeHeight, height: sizeHeight)
            overlayLayer.masksToBounds = true
            playerLayer.addSublayer(overlayLayer)
        }
        return playerLayer
    }()
    
    //MARK: CollectionView delegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return periods.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "videoPreviewCell", for: indexPath) as! VideoPrevieCell
        
        let period = periods[indexPath.item]
        let start = period["start"] as? Int
        let end = period["end"] as? Int
        cell.previewImage.image = thumbnailImage(asset: videoUrl, start: start!)
        cell.previewImage.layer.cornerRadius = 5.0
        cell.previewImage.clipsToBounds = true
        var appColor: UIColor!
        if #available(iOS 11.0, *) {
            appColor = UIColor(named: "appMainColor")!
        } else {
            appColor = UIColor(red: 215/255.0, green: 71/255.0, blue: 14/255.0, alpha: 1.0)
        }
        cell.previewImage.layer.borderColor = appColor.cgColor
//        if cell.isSelected {
//            cell.previewImage.layer.borderWidth = 3.0
//        }else {
//            cell.previewImage.layer.borderWidth = 3.0
//        }
        cell.startDuration.text = String(format: "%02d:%02d", start! / 60, start! % 60)
        cell.endDuration.text = String(format: "%02d:%02d", end! / 60, end! % 60)
        
        return cell
    }
    
    var durationTime = CMTime(seconds: Double(0), preferredTimescale: 1000)
//    var selectedCell = [IndexPath]()
    var lastCell: IndexPath!
    var selectCells = [VideoPrevieCell]()
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected index: \(indexPath)")
        player.pause()
        playButton.setImage(#imageLiteral(resourceName: "play-button"), for: .normal)
        playButton.alpha = 1
        isPlayed = false
        isShowed = true
        playerLayer.removeFromSuperlayer()
        UIView.animate(withDuration: 0.3) {
            self.durationTrackView.alpha = 0
        }
        viewPreview.isUserInteractionEnabled = false
        let start = periods[indexPath.item]["start"] as? Int
        viewPreview.image = thumbnailImage(asset: videoUrl, start: start!)
        let cell = collectionView.cellForItem(at: indexPath) as! VideoPrevieCell
//        selectedCell.append(indexPath)
        lastCell = indexPath
        selectCells.append(cell)
//        if indexPath.item > 0 {
//            let cell = collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as! VideoPrevieCell
//            cell.previewImage.layer.borderWidth = 0
//        }
        cell.isSelected = true
        durationTime = CMTime(seconds: Double(start!), preferredTimescale: 1000)
        player.seek(to: durationTime)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        print("Deselected index: \(indexPath)")
        let cell = selectCells[0]
        cell.isSelected = false
        collectionView.deselectItem(at: indexPath, animated: true)
        selectCells.remove(at: 0)
//        if selectedCell.contains(indexPath) {
//            selectedCell.remove(at: selectedCell.index(of: indexPath)!)
//            cell.previewImage.layer.borderWidth = 0
//        }
    }
    
    func removeBordersFromCells() {
        if lastCell != nil {
            if periods.count <= lastCell.item {
                index = 0
                let firstIndex = IndexPath(item: 0, section: 0)
                collectionView.selectItem(at: firstIndex, animated: false, scrollPosition: .left)
                let start = periods[firstIndex.item]["start"] as? Int
                viewPreview.image = thumbnailImage(asset: videoUrl, start: start!)
                durationTime = CMTime(seconds: Double(start!), preferredTimescale: 1000)
                player.seek(to: durationTime)
            }else {
                index = lastCell.item
                collectionView.selectItem(at: lastCell, animated: false, scrollPosition: .centeredHorizontally)
                let start = periods[lastCell.item]["start"] as? Int
                viewPreview.image = thumbnailImage(asset: videoUrl, start: start!)
                durationTime = CMTime(seconds: Double(start!), preferredTimescale: 1000)
                player.seek(to: durationTime)
            }
        }else {
            index = 0
            let firstIndex = IndexPath(item: 0, section: 0)
            collectionView.selectItem(at: firstIndex, animated: false, scrollPosition: .left)
            let start = periods[firstIndex.item]["start"] as? Int
            viewPreview.image = thumbnailImage(asset: videoUrl, start: start!)
            durationTime = CMTime(seconds: Double(start!), preferredTimescale: 1000)
            player.seek(to: durationTime)
        }
    }
    
    //MARK: AVPlayer methods
    var isPlayed = false
    fileprivate func handlePlayVideo() {
        if !isPlayed {
            isPlayed = true
            isShowed = true
            playButton.alpha = 0
            playButton.setImage(#imageLiteral(resourceName: "media-pause"), for: .normal)
            viewPreview.layer.addSublayer(playerLayer)
            player.play()
            viewPreview.isUserInteractionEnabled = true
            UIView.animate(withDuration: 0.3) {
                self.durationTrackView.alpha = 0
            }
        }else {
            isPlayed = false
            playButton.alpha = 1
            playButton.setImage(#imageLiteral(resourceName: "play-button"), for: .normal)
            viewPreview.isUserInteractionEnabled = false
            player.pause()
            //            playerLayer.removeFromSuperlayer()
        }
    }
    
    @IBAction func playVideo(_ sender: Any) {
        handlePlayVideo()
    }
    
    var isShowed = true
    @objc func showDurationTrackView() {
        if isShowed {
            isShowed = false
            UIView.animate(withDuration: 0.3) {
                self.playButton.alpha = 1
                self.durationTrackView.alpha = 1
            }
//            Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(hideTimeDurationView), userInfo: nil, repeats: false)
        }else {
            isShowed = true
            UIView.animate(withDuration: 0.3) {
                self.playButton.alpha = 0
                self.durationTrackView.alpha = 0
            }
        }
    }
    
    @objc func hideTimeDurationView() {
        isShowed = true
        UIView.animate(withDuration: 0.3) {
            if self.isPlayed {
                self.playButton.alpha = 0
            }
            self.durationTrackView.alpha = 0
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        player.pause()
    }
    
    //MARK: Animate In method
    let keyWindow = UIApplication.shared.keyWindow
    var blurView = UIVisualEffectView()
    var assetExport: AVAssetExportSession?
    
    func animateIn(proVersionView: UIView?, cancelButton: UIButton?, completion: @escaping () -> ()) {
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        blurView.frame = (keyWindow?.frame)!
        blurView.effect = blurEffect
        blurView.alpha = 0
        keyWindow?.addSubview(blurView)
        
        if proVersionView != nil {
            keyWindow?.addSubview(proVersionView!)
        }
        
        if cancelButton != nil {
            keyWindow?.addSubview(cancelButton!)
        }
        
        UIView.animate(withDuration: 0.4) {
            self.blurView.alpha = 1.0
            if proVersionView != nil && cancelButton != nil {
                proVersionView?.alpha = 1.0
                proVersionView?.frame.origin.y = 100
                cancelButton?.alpha = 1.0
            }
        }
        completion()
    }
    
    func animateOut(proVersionView: UIView?, cancelButton: UIButton?, completion: @escaping () -> ()) {
        if proVersionView != nil && cancelButton != nil {
            UIView.animate(withDuration: 0.4) {
                self.blurView.alpha = 0
                proVersionView?.frame.origin.y = self.view.frame.height
                proVersionView?.alpha = 0
                cancelButton?.alpha = 0
            }
            completion()
        }else {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.3) {
                UIView.animate(withDuration: 0.4) {
                    self.blurView.alpha = 0
                }
                completion()
            }
        }
    }
    
    let dispatchGroup = DispatchGroup()
    let dispatchQueue = DispatchQueue(label: "taskQueue")
    let dispatchSemaphore = DispatchSemaphore(value: 0)
    let waitTitle = NSLocalizedString("WAIT", comment: "")
   
    lazy var hud: JGProgressHUD = {
        let hud = JGProgressHUD(style: .light)
        hud.textLabel.text = "\(waitTitle) ..."
        hud.textLabel.textColor = .white
        hud.detailTextLabel.textColor = .lightGray
        return hud
    }()
    
    @IBAction func saveVideosToPhotolibary(_ sender: Any) {
        print("Can save: \(isCanSave)")
        isPlayed = false
        playButton.alpha = 1
        playButton.setImage(#imageLiteral(resourceName: "play-button"), for: .normal)
        viewPreview.isUserInteractionEnabled = false
        player.pause()
        UIView.animate(withDuration: 0.3) {
            self.durationTrackView.alpha = 0
        }
        animateIn(proVersionView: nil, cancelButton: nil) {
            self.hud.show(in: self.keyWindow!)
        }
        
        if isCanSave {
            dispatchQueue.async {
                for i in 0..<self.periods.count {
                    self.dispatchGroup.enter()
                    print("Request: \(i) begin at \(Date())")
                    let start = self.periods[i]["start"] as? Int
                    let end = self.periods[i]["end"] as? Int
                    self.saveVideos(with: self.videoUrl, start: start!, end: end!, index: i)
                }
            }
            
            dispatchGroup.notify(queue: dispatchQueue) {
                DispatchQueue.main.async {
                    self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                    let succesTitle = NSLocalizedString("SUCCES", comment: "")
                    self.hud.textLabel.text = succesTitle
                    self.hud.detailTextLabel.isHidden = true
                    self.hud.indicatorView?.tintColor = UIColor(red:0.36, green:0.80, blue:0.68, alpha:1.0)
                    self.hud.dismiss(afterDelay: 2.0, animated: true)
                    self.animateOut(proVersionView: nil, cancelButton: nil) {
                        self.hud.indicatorView = JGProgressHUDIndeterminateIndicatorView()
                        self.hud.textLabel.text = "\(self.waitTitle) ..."
                        if !isProVersion && isGetedProduct {
                            self.showProVersionView()
                        }
                    }
                }
            }
        }else {
            DispatchQueue.main.async {
                self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                let memoryTitle = NSLocalizedString("MEMORY", comment: "")
                self.hud.textLabel.text = "\(memoryTitle)!"
                self.hud.detailTextLabel.isHidden = true
                self.hud.indicatorView?.tintColor = .red
                self.hud.dismiss(afterDelay: 2.0, animated: true)
                self.animateOut(proVersionView: nil, cancelButton: nil) {
                    self.hud.indicatorView = JGProgressHUDIndeterminateIndicatorView()
                    self.hud.textLabel.text = "\(self.waitTitle) ..."
                }
            }
        }
        
    }
    
    func saveVideos(with sourceURL1: URL, start: Int, end: Int, index: Int) {
        let manager = FileManager.default
        
        guard let documentDirectory = try? manager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else {return}
        guard let mediaType = "mp4" as? String else {return}
        guard (sourceURL1 as? NSURL) != nil else {return}
        
        if mediaType == kUTTypeMovie as String || mediaType == "mp4" as String {
            
//        let asset = AVAsset(url: sourceURL1)
        
            var outputURL = documentDirectory.appendingPathComponent("output")
            do {
                try manager.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
                let timestamp: NSNumber = NSNumber(value: Int(NSDate().timeIntervalSince1970))
                let name = "outputVideo-\(index + 1)-\(timestamp)"
                outputURL = outputURL.appendingPathComponent("\(name).mp4")
            }catch let error {
                print(error)
            }
            
            //Remove existing file
            
            let startTime = CMTime(seconds: Double(start), preferredTimescale: 1000)
            let endTime = CMTime(seconds: Double(end), preferredTimescale: 1000)
            let timeRange = CMTimeRange(start: startTime, end: endTime)
            
            let composition = AVMutableComposition()
            let asset = AVURLAsset(url: sourceURL1 as URL, options: nil)
            
            let track =  asset.tracks(withMediaType: AVMediaType.video)
            let videoTrack:AVAssetTrack = track[0] as AVAssetTrack
            let timerange = CMTimeRangeMake(kCMTimeZero, asset.duration)
            
            let compositionVideoTrack:AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: CMPersistentTrackID())!
            
            do {
                try compositionVideoTrack.insertTimeRange(timerange, of: videoTrack, at: kCMTimeZero)
                compositionVideoTrack.preferredTransform = videoTrack.preferredTransform
            } catch {
                print(error)
            }
            
            let compositionAudioTrack:AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: CMPersistentTrackID())!
            
            for audioTrack in asset.tracks(withMediaType: AVMediaType.audio) {
                do {
                    try compositionAudioTrack.insertTimeRange(timeRange, of: audioTrack, at: startTime)
                } catch {
                    print(error)
                }
                
            }
            //
            let size = videoTrack.naturalSize
            
            let watermark = #imageLiteral(resourceName: "Cutter-maska").cgImage
            let watermarklayer = CALayer()
            watermarklayer.contents = watermark
            let sizeConst: CGFloat = size.height > size.width ? 10 : 5
            
            let sizeHeight = size.height / sizeConst
            watermarklayer.frame = CGRect(x: size.width - (sizeHeight * 1.3), y: sizeHeight / 2, width: sizeHeight, height: sizeHeight)
            watermarklayer.opacity = 1
            
            let videolayer = CALayer()
            videolayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            
            let parentlayer = CALayer()
            parentlayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            parentlayer.addSublayer(videolayer)
            parentlayer.addSublayer(watermarklayer)
            
            let layercomposition = AVMutableVideoComposition()
            layercomposition.frameDuration = CMTimeMake(1, 30)
            layercomposition.renderSize = CGSize(width: size.width, height: size.height)
            layercomposition.renderScale = 1.0
            layercomposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videolayer, in: parentlayer)
            
            let instruction = AVMutableVideoCompositionInstruction()
            instruction.timeRange = CMTimeRangeMake(kCMTimeZero, composition.duration)
            
            let videotrack = composition.tracks(withMediaType: AVMediaType.video)[0] as AVAssetTrack
            let layerinstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videotrack)
            
            layerinstruction.setTransform(videoTrack.preferredTransform, at: kCMTimeZero)
            
            instruction.layerInstructions = [layerinstruction]
            layercomposition.instructions = [instruction]
            
            assetExport = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetMediumQuality)
            guard assetExport != nil else { return }
            if !isProVersion {
                assetExport?.videoComposition = layercomposition
            }
            assetExport?.outputFileType = AVFileType.mp4
            
            assetExport?.outputURL = outputURL
            assetExport?.timeRange = timeRange
        
    //        exportSession.timeRange = timeRange
            assetExport?.exportAsynchronously(completionHandler: {
                switch self.assetExport?.status {
                case .completed?:
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputURL)
                    }) { saved, error in
                        if saved {
                            print("Finished request: \(index) at \(Date())")
                            self.dispatchSemaphore.signal()
                            self.dispatchGroup.leave()
                            _ = try? manager.removeItem(at: outputURL)
                        }
                    }
                case .failed?:
                    print("failed \(self.assetExport?.error)")
                    
                case .cancelled?:
                    print("cancelled Export session \(self.assetExport?.error)")
                    
                default: break
                }
            })
            dispatchSemaphore.wait()
            
        }
    }
    
    
}







