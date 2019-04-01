//
//  SavingVideosHelper.swift
//  InstaCut
//
//  Created by Kazim Gajiev on 28/03/2019.
//  Copyright © 2019 Kazim Gajiev. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices

protocol SavingVideosHelperProtocol: class {
    func saveVideos(from videoURL: URL, with periods: [VideoPeriods])
}

class SavingVideosHelper: SavingVideosHelperProtocol, IterationObserver {
    
    private var videoURL: URL?
    
    private let observerCenter = ObserverCenters()
    private let photoLibraryManager: PhotoLibraryManager

    init(popUpView: PopUpViewController, photoLibraryManager: PhotoLibraryManager) {
        self.photoLibraryManager = photoLibraryManager
        observerCenter.subscribe(self)
        observerCenter.subscribe(popUpView)
    }

    let dispatchGroup = DispatchGroup()
    let dispatchQueue = DispatchQueue(label: "taskQueue")
    let dispatchSemaphore = DispatchSemaphore(value: 0)
    
    func saveVideos(from videoURL: URL, with periods: [VideoPeriods]) {
        self.videoURL = videoURL
        
        dispatchQueue.async {
            for i in 0..<periods.count {
                self.dispatchGroup.enter()
                let period = periods[i]
                self.saveVideoToPhotoAlbum(index: i, start: period.start, end: period.end)
            }
        }
    }
    
    private let fileManager = FileManager.default
    
    private func saveVideoToPhotoAlbum(index: Int, start: Double, end: Double) {
        
        let outputURL = createDirectory(index: index)
        guard let url = videoURL else { return }
        
        let startTime = CMTime(seconds: start, preferredTimescale: 1000)
        let endTime = CMTime(seconds: end, preferredTimescale: 1000)
        let timeRange = CMTimeRange(start: startTime, end: endTime)
        
        let asset = AVAsset(url: url)
        
        
    }
    
    private func createDirectory(index: Int) -> URL {
        guard let documentDirectory = try? fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else {return}
            
        var outputURL = documentDirectory.appendingPathComponent("output")
        do {
            let name = "outputVideo_\(index + 1)_\(Int(Date().timeIntervalSince1970))"
            outputURL = outputURL.appendingPathComponent("\(name).mp4")
            //                try manager.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
        }catch let error {
            print(error)
        }
        
        return outputURL
    }
    
    private func removeFileFromDirectory(outputURL: URL) {
        try? fileManager.removeItemAtURL(outputURL)
    }
    
    private func exportToCameraRoll(with timeRange: CMTimeRange, and asset: AVAsset, to outputURL: URL) {
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else {return}
        exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileType.mp4
        
        exportSession.timeRange = timeRange
        exportSession.exportAsynchronously {
            switch exportSession.status {
            case .Completed:
                print("exported at \(outputURL)")
                self.photoLibraryManager.saveVideoToCameraRoll(videoURL: outputURL, completion: { (saved, error) in
                    if saved && error == nil {
                        self.removeFileFromDirectory(outputURL: outputURL)
                        self.dispatchGroup.leave()
                    }
                })
            case .Failed:
                print("failed \(exportSession.error)")
                
            case .Cancelled:
                print("cancelled \(exportSession.error)")
                
            default: break
            }
        }
    }
    
}
