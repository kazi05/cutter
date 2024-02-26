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
    private let renderedPlayerItem: AVPlayerItem?
    private let processor: VideoPreviewRenderProcessor
    private var predictor: RVMPredictable!
    private let videoOutput: AVPlayerItemVideoOutput
    private let renderedVideoOutput: AVPlayerItemVideoOutput?
    private var eraseBackgroundEnabled: Bool
    private var isNeedRotate = false

    let device: MTLDevice

    private var subscriptions = Set<AnyCancellable>()

    init(
        playerItem: AVPlayerItem,
        renderedPlayerItem: AVPlayerItem?,
        erasingBackground: Bool,
        device: MTLDevice
    ) {
        self.playerItem = playerItem
        self.device = device
        self.processor = .init(device: device)
        self.eraseBackgroundEnabled = erasingBackground
        let pixelBufferAttributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA),
            kCVPixelBufferMetalCompatibilityKey as String: true
        ]
        self.videoOutput = AVPlayerItemVideoOutput(pixelBufferAttributes: pixelBufferAttributes)
        if let renderedPlayerItem {
            self.renderedPlayerItem = renderedPlayerItem
            self.renderedVideoOutput = AVPlayerItemVideoOutput(pixelBufferAttributes: pixelBufferAttributes)
        } else {
            self.renderedPlayerItem = nil
            self.renderedVideoOutput = nil
        }
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

        if let renderedPlayerItem, let renderedVideoOutput {
            renderedPlayerItem.publisher(for: \.status).sink { status in
                switch status {
                case .readyToPlay:
                    renderedPlayerItem.add(renderedVideoOutput)
                default:
                    break
                }
            }.store(in: &subscriptions)
        }
    }

    public func setupVideoSize(_ videoSize: CGSize, isNeedRotate: Bool) {
        self.isNeedRotate = isNeedRotate
        let maxVideoSize = max(videoSize.width, videoSize.height)
        let isPortrait = videoSize.width < videoSize.height
        switch maxVideoSize {
        case 1281...1920:
            self.predictor = isPortrait ? RVMPredictorFHD_P() : RVMPredictorFHD()
        case 1921...3840:
            self.predictor = isPortrait ? RVMPredictor4K_P() : RVMPredictor4K()
        default:
            self.predictor = isPortrait ? RVMPredictorHD_P() : RVMPredictorHD()
        }
    }

    public func getCurrentFrameTexture() -> MTLTexture? {
        var textureCache: CVMetalTextureCache?
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
        let pixelBuffer = if let renderedVideoOutput, eraseBackgroundEnabled {
            renderedVideoOutput.copyPixelBuffer(forItemTime: currentTime, itemTimeForDisplay: nil)
        } else {
            videoOutput.copyPixelBuffer(forItemTime: currentTime, itemTimeForDisplay: nil)
        }
        guard var pixelBuffer else {
            return nil
        }

        if !(renderedVideoOutput != nil && eraseBackgroundEnabled) && isNeedRotate, let rotated = pixelBuffer.rotate90PixelBuffer(factor: 3) {
            pixelBuffer = rotated
        }

        if eraseBackgroundEnabled && renderedVideoOutput == nil, let processedTexture = processFrame(pixelBuffer) {
            return processedTexture
        }

        guard let texture = createTexture(from: pixelBuffer, cache: textureCache) else {
            return nil
        }

        return texture
    }

    func processVideoFrames(
        to destinationURL: URL,
        progress: VideoRenderProgressState
    ) async throws -> AVAsset? {
        // Создаем AVAsset и AVAssetReader
        let asset = playerItem.asset
        guard let assetReader = try? AVAssetReader(asset: asset) else {
            throw NSError(domain: "Error creating AVAssetReader", code: 0, userInfo: nil)
        }

        guard let videoTrack = try await asset.loadTracks(withMediaType: .video).first,
              let audioTrack = try await asset.loadTracks(withMediaType: .audio).first
        else {
            throw NSError(domain: "Video track not found", code: 1, userInfo: nil)
        }

        let readerOutputSettings: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]
        let readerOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: readerOutputSettings)
        assetReader.add(readerOutput)

        // Подготовка AVAssetWriter
        guard let assetWriter = try? AVAssetWriter(outputURL: destinationURL, fileType: .mov) else {
            throw NSError(domain: "Error creating AVAssetWriter", code: 0, userInfo: nil)
        }

        // Настройки для видеоинпута
        let transform = try await videoTrack.load(.preferredTransform)
        let videoSize = try await videoTrack.load(.naturalSize).applying(transform)
        let videoDuration = try await asset.load(.duration)
        let writerInputSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: abs(videoSize.width),
            AVVideoHeightKey: abs(videoSize.height)
        ]
        let videoWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: writerInputSettings)
        assetWriter.add(videoWriterInput)
        let pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: videoWriterInput, sourcePixelBufferAttributes: nil)

        // Создаем AVAssetWriterInput для аудио, если аудиотрек существует
        let audioOutputSettings: [String: Any] = [
            AVFormatIDKey: kAudioFormatLinearPCM
        ]
        let audioReaderOutput = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: audioOutputSettings)
        if assetReader.canAdd(audioReaderOutput) {
            assetReader.add(audioReaderOutput)
        }

        // Настройка записи аудиодорожки
        let audioInputSettings: [String : Any] = [
            AVNumberOfChannelsKey: 2,
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: 44100,
            AVEncoderBitRateKey: 128000,
        ]
        let audioWriterInput = AVAssetWriterInput(mediaType: .audio, outputSettings: audioInputSettings)
        if assetWriter.canAdd(audioWriterInput) {
            assetWriter.add(audioWriterInput)
        }

        assetReader.startReading()
        assetWriter.startWriting()
        assetWriter.startSession(atSourceTime: CMTime.zero)

        let processingQueue = DispatchQueue(label: "processingQueue")

        progress.handleCancel {
            VideoOutputFileManager.shared.deleteFiles()
            assetReader.cancelReading()
            assetWriter.cancelWriting()
        }

        return try await withCheckedThrowingContinuation { continuation in
            processingQueue.async {
                var videoFinished = false
                var audioFinished = false

                while assetReader.status == .reading && (!videoFinished || !audioFinished) {
                    autoreleasepool {
                        if videoWriterInput.isReadyForMoreMediaData, !videoFinished {
                            if let sampleBuffer = readerOutput.copyNextSampleBuffer() {
                                let presentationTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
                                if let processedPixelBuffer = self.processFrame(sampleBuffer) {
                                    pixelBufferAdaptor.append(processedPixelBuffer, withPresentationTime: presentationTime)
                                    progress.updateProgress(presentationTime.seconds / videoDuration.seconds)
                                }
                            } else {
                                videoWriterInput.markAsFinished()
                                videoFinished = true
                            }
                        }
                        
                        if audioWriterInput.isReadyForMoreMediaData, !audioFinished {
                            if let sampleBuffer = audioReaderOutput.copyNextSampleBuffer() {
                                audioWriterInput.append(sampleBuffer)
                            } else {
                                audioWriterInput.markAsFinished()
                                audioFinished = true
                            }
                        }
                    }
                }
                

                if assetReader.status == .completed {
                    assetWriter.finishWriting {
                        if assetWriter.status == .failed {
                            continuation.resume(throwing: assetWriter.error ?? NSError(domain: "AssetWriterError", code: -1, userInfo: nil))
                        } else {
                            continuation.resume(returning: AVAsset(url: destinationURL))
                        }
                    }
                } else {
                    continuation.resume(throwing: NSError(domain: "AssetReaderError", code: -2, userInfo: nil))
                }
            }
        }
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
        let (fgr, pha) = predictor.predict(src: frame)
        guard let bgraPha = pha.toBGRApixelBuffer() else {
            return nil
        }
        return processor.eraseBackground(
            from: fgr,
            mask: bgraPha
        )
    }

    private func processFrame(_ frame: CMSampleBuffer) -> CVPixelBuffer? {
        guard var frame = CMSampleBufferGetImageBuffer(frame) else {
          return nil
        }
        if isNeedRotate, let rotated = frame.rotate90PixelBuffer(factor: 3) {
            frame = rotated
        }
        let (fgr, pha) = predictor.predict(src: frame)
        
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
