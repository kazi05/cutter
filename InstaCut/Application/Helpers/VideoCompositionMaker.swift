//
//  VideoCompositionMaker.swift
//  InstaCut
//
//  Created by Kazim Gadjiev on 15.10.2020.
//  Copyright © 2020 Kazim Gajiev. All rights reserved.
//

import UIKit
import AVFoundation

class VideoCompositionMaker {
    
    private let asset: AVAsset
    private(set) var videoComposition: AVMutableVideoComposition?
    
    init(asset: AVAsset) {
        self.asset = asset
    }
    
    func generateComposition(with range: CMTimeRange) -> AVMutableComposition? {
        let composition = AVMutableComposition()
        
        guard
            let compositionTrack = composition.addMutableTrack(
                withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid),
            let assetTrack = asset.tracks(withMediaType: .video).first
        else {
            print("Something is wrong with the asset.")
            return nil
        }
        
        do {
            try compositionTrack.insertTimeRange(range, of: assetTrack, at: .zero)
            
            if let audioAssetTrack = asset.tracks(withMediaType: .audio).first,
               let compositionAudioTrack = composition.addMutableTrack(
                withMediaType: .audio,
                preferredTrackID: kCMPersistentTrackID_Invalid) {
                try compositionAudioTrack.insertTimeRange(
                    range,
                    of: audioAssetTrack,
                    at: .zero)
            }
        } catch {
            print(error.localizedDescription)
            return nil
        }
        
        compositionTrack.preferredTransform = assetTrack.preferredTransform
        let videoInfo = orientation(from: assetTrack.preferredTransform)
        
        let videoSize: CGSize
        if videoInfo.isPortrait {
            videoSize = CGSize(
                width: assetTrack.naturalSize.height,
                height: assetTrack.naturalSize.width)
        } else {
            videoSize = assetTrack.naturalSize
        }
        
        let videoLayer = CALayer()
        videoLayer.frame = CGRect(origin: .zero, size: videoSize)

        let outputLayer = CALayer()
        outputLayer.frame = CGRect(origin: .zero, size: videoSize)
        outputLayer.addSublayer(videoLayer)
        
        if UserDefaults.standard.value(forKey: IAPProductKind.mask.rawValue) == nil {
            addImageMask(to: outputLayer, videoSize: videoSize)
        }
        
        if UserDefaults.standard.value(forKey: IAPProductKind.progress.rawValue) != nil {
            addProgressView(to: outputLayer, videoSize: videoSize, duration: range.duration.seconds)
        }
        
        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = videoSize
        videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
        videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(
            postProcessingAsVideoLayer: videoLayer,
            in: outputLayer
        )
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRange(
            start: .zero,
            duration: composition.duration
        )
        videoComposition.instructions = [instruction]
        
        let layerInstruction = compositionLayerInstruction(
            for: compositionTrack,
            assetTrack: assetTrack)
        instruction.layerInstructions = [layerInstruction]
        
        if UserDefaults.standard.value(forKey: IAPProductKind.mask.rawValue) == nil ||
            UserDefaults.standard.value(forKey: IAPProductKind.progress.rawValue) != nil {
            self.videoComposition = videoComposition
        }
        
        return composition
    }
    
    private func orientation(from transform: CGAffineTransform) -> (orientation: UIImage.Orientation, isPortrait: Bool) {
        var assetOrientation = UIImage.Orientation.up
        var isPortrait = false
        if transform.a == 0 && transform.b == 1.0 && transform.c == -1.0 && transform.d == 0 {
            assetOrientation = .right
            isPortrait = true
        } else if transform.a == 0 && transform.b == -1.0 && transform.c == 1.0 && transform.d == 0 {
            assetOrientation = .left
            isPortrait = true
        } else if transform.a == 1.0 && transform.b == 0 && transform.c == 0 && transform.d == 1.0 {
            assetOrientation = .up
        } else if transform.a == -1.0 && transform.b == 0 && transform.c == 0 && transform.d == -1.0 {
            assetOrientation = .down
        }
        
        return (assetOrientation, isPortrait)
    }
    
    private func compositionLayerInstruction(for track: AVCompositionTrack, assetTrack: AVAssetTrack) -> AVMutableVideoCompositionLayerInstruction {
        let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
        let transform = assetTrack.preferredTransform
        
        instruction.setTransform(transform, at: .zero)
        
        return instruction
    }
    
    private func addImageMask(to layer: CALayer, videoSize: CGSize) {
        let image = UIImage(named: "Cutter-maska")!
        let imageLayer = CALayer()
        
        let wide = min(videoSize.width, videoSize.height) / 7
        imageLayer.frame = CGRect(
            x: videoSize.width - wide * 1.5,
            y: wide / 2,
            width: wide,
            height: wide
        )
        imageLayer.contents = image.cgImage
        layer.addSublayer(imageLayer)
    }
    
    private func addProgressView(to layer: CALayer, videoSize: CGSize, duration: Double) {
        let progressLayer = CAShapeLayer()
        progressLayer.fillColor = nil
        progressLayer.strokeColor = UIColor(named: "appMainColor")?.cgColor
        
        let wide = min(videoSize.width, videoSize.height) / 40
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: wide / 2))
        path.addLine(to: CGPoint(x: videoSize.width, y: wide / 2))
        
        progressLayer.path = path.cgPath
        progressLayer.lineWidth = wide
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.beginTime = AVCoreAnimationBeginTimeAtZero
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = duration
        animation.isRemovedOnCompletion = false
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        
        progressLayer.add(animation, forKey: nil)
        
        layer.addSublayer(progressLayer)
    }
    
}
