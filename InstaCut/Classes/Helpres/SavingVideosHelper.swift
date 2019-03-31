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
    
    private var url: URL?
    
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
        self.url = videoURL
        
        dispatchQueue.async {
            for i in 0..<periods.count {
                self.dispatchGroup.enter()
                let period = periods[i]
                self.saveVideoToPhotoAlbum(index: i, start: period.start, end: period.end)
            }
        }

//        dispatchGroup.async {
//            DispatchQueue.concurrentPerform(iterations: periods.count, execute: { (id: Int) in
//                sleep(UInt32(id + 1))
//                let period = periods[id]
//                self.saveVideoToPhotoAlbum(index: id, start: period.start, end: period.end)
//            })
//        }
        
    }
    
    private func saveVideoToPhotoAlbum(index: Int, start: Double, end: Double) {
        let manager = FileManager.default

        guard let documentDirectory = try? manager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else {return}
        guard let mediaType = "mp4" as? String else {return}
        guard let url = url else {return}
        
        if mediaType == kUTTypeMovie as String || mediaType == "mp4" as String {

            var outputURL = documentDirectory.appendingPathComponent("output")
            do {
                let name = "outputVideo_\(index + 1)_\(Int(Date().timeIntervalSince1970))"
                outputURL = outputURL.appendingPathComponent("\(name).mp4")
//                try manager.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
            }catch let error {
                print(error)
            }
            
            let startTime = CMTime(seconds: start, preferredTimescale: 1000)
            let endTime = CMTime(seconds: end, preferredTimescale: 1000)
            let timeRange = CMTimeRange(start: startTime, end: endTime)
            
            let mixComposition = AVMutableComposition()
            let asset = AVURLAsset(url: url, options: nil)
            
            guard let videoTrack = asset.tracks(withMediaType: AVMediaType.video).first else { return }
            let size = videoTrack.naturalSize
            let layerSize = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            let compositionTimeRange = CMTimeRangeMake(kCMTimeZero, asset.duration)

            guard let compositionVideoTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: CMPersistentTrackID(kCMPersistentTrackID_Invalid)),
                let compositionAudioTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: CMPersistentTrackID(kCMPersistentTrackID_Invalid)) else { return }

            let sourceVideoTrack = asset.tracks(withMediaType: AVMediaType.video).first!
            do {
                try compositionVideoTrack.insertTimeRange(timeRange, of: sourceVideoTrack, at: kCMTimeZero)
                compositionVideoTrack.preferredTransform = videoTrack.preferredTransform
                if let sourceAudioTrack = asset.tracks(withMediaType: AVMediaType.audio).first {
                    try compositionAudioTrack.insertTimeRange(timeRange, of: sourceAudioTrack, at: kCMTimeZero)
                }
            } catch {
                print(error)
                return
            }

            let videoLayer = CALayer()
            videoLayer.frame = layerSize
            videoLayer.addLogoMask(reverse: true)

            let parentLayer = CALayer()
            parentLayer.frame = layerSize
            parentLayer.addSublayer(videoLayer)

            //
            let videoComp = AVMutableVideoComposition()
            videoComp.renderSize = size
            videoComp.frameDuration = CMTimeMake(1, 30)
            videoComp.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
            // Set the video composition to apply to the composition video track
            let instruction = AVMutableVideoCompositionInstruction()
            instruction.timeRange = CMTimeRangeMake(kCMTimeZero, mixComposition.duration)

            let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
            instruction.layerInstructions = [layerInstruction]
            videoComp.instructions = [instruction]
//
            guard let exportSession = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetMediumQuality) else {return}
            exportSession.outputURL = outputURL
            exportSession.outputFileType = AVFileType.mp4
            exportSession.videoComposition = videoComp
//            exportSession.timeRange = timeRange
            
            exportSession.exportAsynchronously {
                switch exportSession.status {
                case .completed:
                    print("exported at \(exportSession.outputURL)")
                    self.photoLibraryManager.saveVideoToCameraRoll(videoURL: exportSession.outputURL!, completion: { (saved, error) in
                        if saved {
                            self.dispatchSemaphore.signal()
                            self.dispatchGroup.leave()
                            self.observerCenter.notify(index: index)
                            _ = try? manager.removeItem(at: outputURL)
                        }
                    })
                case .failed:
                    print("failed \(exportSession.error?.localizedDescription)")
                    self.dispatchSemaphore.signal()
                    self.dispatchGroup.leave()
                case .cancelled:
                    print("cancelled \(exportSession.error)")
                default: break
                }
            }
            dispatchSemaphore.wait()
        }
    }
    
}
