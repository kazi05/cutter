//
//  VideoPreviewRenderer.swift
//  Cutter
//
//  Created by Гаджиев Казим on 27.01.2024.
//

import AVFoundation
import Combine
import CoreML

final class VideoPreviewRenderer {
    private let playerItem: AVPlayerItem
    private let processor: VideoPreviewRenderProcessor
    private var predictor: RVMPredictable!
    private let videoOutput: AVPlayerItemVideoOutput
    private var textureCache: CVMetalTextureCache?
    private var eraseBackgroundEnabled = false
    private(set) var isNeedRotate = false

    let device: MTLDevice

    private var subscriptions = Set<AnyCancellable>()

    init(playerItem: AVPlayerItem, device: MTLDevice) {
        self.playerItem = playerItem
        self.device = device
        self.processor = .init(device: device)
        let pixelBufferAttributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA),
            kCVPixelBufferMetalCompatibilityKey as String: true
        ]
        self.videoOutput = AVPlayerItemVideoOutput(pixelBufferAttributes: pixelBufferAttributes)
        setupVideoOutput()
    }
    
    private func setupVideoOutput() {
        playerItem.publisher(for: \.status).sink { [unowned self] status in
            switch status {
            case .readyToPlay:
                playerItem.add(videoOutput)
            default:
                break
            }
        }.store(in: &subscriptions)
    }

    public func setupVideoSize(_ videoSize: CGSize, isNeedRotate: Bool) {
        self.isNeedRotate = isNeedRotate
        let maxVideoSize = max(videoSize.width, videoSize.height)
        if maxVideoSize > 1280 {
            self.predictor = RVMPredictorFHD()
        } else {
            self.predictor = RVMPredictorHD()
        }
    }

    public func getCurrentFrameTexture() -> MTLTexture? {
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

        if eraseBackgroundEnabled, let processedTexture = processFrame(pixelBuffer) {
            return processedTexture
        }

        guard let texture = createTexture(from: pixelBuffer, cache: textureCache) else {
            return nil
        }

        return texture
    }

    private func createTexture(from pixelBuffer: CVPixelBuffer, cache: CVMetalTextureCache) -> MTLTexture? {
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        
        var cvMetalTexture: CVMetalTexture?
        let result = CVMetalTextureCacheCreateTextureFromImage(
            kCFAllocatorDefault,
            cache,
            pixelBuffer,
            nil,
            .bgra8Unorm,
            width,
            height,
            0,
            &cvMetalTexture
        )

        guard result == kCVReturnSuccess,
              let cvMetalTexture = cvMetalTexture
        else { return nil }

        return CVMetalTextureGetTexture(cvMetalTexture)
    }

    private func processFrame(_ frame: CVPixelBuffer) -> MTLTexture? {
        var resizedFrame = frame
        let initialWidth = CVPixelBufferGetWidth(frame)
        let initialHeight = CVPixelBufferGetHeight(frame)
        let inputWidth = predictor.inputWidth
        let inputHeight = predictor.inputHeight
        let needResize = initialWidth < initialHeight || initialWidth > inputWidth
        if needResize, let resized = frame.resizePixelBuffer(width: inputWidth, height: inputHeight) {
            resizedFrame = resized
        }
        var (fgr, pha) = predictor.predict(src: resizedFrame)
        if needResize,
           let originalFgr = fgr.resizePixelBuffer(width: initialWidth, height: initialHeight),
           let originalPha = pha.resizePixelBuffer(width: initialWidth, height: initialHeight){
            fgr = originalFgr
            pha = originalPha
        }
        guard let bgraPha = pha.toBGRApixelBuffer() else {
            return nil
        }
        return processor.eraseBackground(
            from: fgr.toCGImage(),
            maskImage: bgraPha.toCGImage()
        )
    }

    public func setEraseBackgroundEnabled(_ enabled: Bool) {
        eraseBackgroundEnabled = enabled
    }
}
