//
//  VideoPreviewRenderer.swift
//  Cutter
//
//  Created by Гаджиев Казим on 27.01.2024.
//

import AVFoundation

final class VideoPreviewRenderer {
    private let playerItem: AVPlayerItem
    private let videoOutput: AVPlayerItemVideoOutput
    private var textureCache: CVMetalTextureCache?
    
    init(playerItem: AVPlayerItem) {
        self.playerItem = playerItem
        let pixelBufferAttributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA),
            kCVPixelBufferMetalCompatibilityKey as String: true
        ]
        self.videoOutput = AVPlayerItemVideoOutput(pixelBufferAttributes: pixelBufferAttributes)
        setupVideoOutput()
    }
    
    private func setupVideoOutput() {
        playerItem.add(videoOutput)
    }
    
    func getCurrentFrameTexture(device: MTLDevice) -> MTLTexture? {
        if textureCache == nil {
            var cache: CVMetalTextureCache?
            CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, device, nil, &cache)
            textureCache = cache
        }
        
        guard let textureCache = textureCache else {
            return nil
        }
        
        guard videoOutput.hasNewPixelBuffer(forItemTime: playerItem.currentTime()) else {
            return nil
        }
        
        let currentTime = playerItem.currentTime()
        guard let pixelBuffer = videoOutput.copyPixelBuffer(forItemTime: currentTime, itemTimeForDisplay: nil) else {
            return nil
        }
        
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        
        var cvMetalTexture: CVMetalTexture?
        let result = CVMetalTextureCacheCreateTextureFromImage(
            kCFAllocatorDefault,
            textureCache,
            pixelBuffer,
            nil,
            .bgra8Unorm,
            width,
            height,
            0,
            &cvMetalTexture
        )
        
        if result == kCVReturnSuccess, let cvMetalTexture = cvMetalTexture {
            return CVMetalTextureGetTexture(cvMetalTexture)
        } else {
            return nil
        }
    }
}
