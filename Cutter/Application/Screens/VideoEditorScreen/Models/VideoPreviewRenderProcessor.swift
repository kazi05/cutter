//
//  VideoPreviewRenderProcessor.swift
//  Cutter
//
//  Created by Гаджиев Казим on 18.02.2024.
//

import AVFoundation
import MetalKit
import Accelerate

final class VideoPreviewRenderProcessor {
    private let device: MTLDevice
    private let commandQueue: MTLCommandQueue
    private let pipelineState: MTLComputePipelineState
    private let resizePipelineState: MTLComputePipelineState
    private var textureCache: CVMetalTextureCache?

    private struct RenderParameters {
        let convertToBGRA: Bool
        let shouldRotate: Bool
    }

    init(device: MTLDevice) {
        self.device = device
        self.commandQueue = device.makeCommandQueue()!
        let library = device.makeDefaultLibrary()!
        let kernelFunction = library.makeFunction(name: "bg_erase")!
        self.pipelineState = try! device.makeComputePipelineState(function: kernelFunction)
        let resizeFunction = library.makeFunction(name: "resize_image")!
        self.resizePipelineState = try! device.makeComputePipelineState(function: resizeFunction)
        CVMetalTextureCacheCreate(nil, nil, device, nil, &textureCache)
    }

    public func eraseBackground(from image: CGImage, maskImage: CGImage) -> MTLTexture? {
        let width = image.width
        let height = image.height
        // Создаем выходную текстуру
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .rgba8Unorm,
            width: width,
            height: height,
            mipmapped: false
        )
        descriptor.usage = [.shaderWrite, .shaderRead]
        let outputTexture = device.makeTexture(descriptor: descriptor)!

        let textureLoader = MTKTextureLoader(device: device)
        guard let originalTexture = try? textureLoader.newTexture(cgImage: image),
              let maskTexture = try? textureLoader.newTexture(cgImage: maskImage)
        else { return nil }

        // Обработка
        let commandBuffer = commandQueue.makeCommandBuffer()!
        let commandEncoder = commandBuffer.makeComputeCommandEncoder()!
        commandEncoder.setComputePipelineState(pipelineState)
        commandEncoder.setTexture(originalTexture, index: 0)
        commandEncoder.setTexture(maskTexture, index: 1)
        commandEncoder.setTexture(outputTexture, index: 2)

        var renderParams = RenderParameters(convertToBGRA: false, shouldRotate: false)
        let renderParamsBuffer = device.makeBuffer(bytes: &renderParams, length: MemoryLayout<RenderParameters>.size, options: [])
        commandEncoder.setBuffer(renderParamsBuffer, offset: 0, index: 0)

        // Запуск шейдера
        let threadsPerGroup = MTLSize(width: 16, height: 16, depth: 1)
        let numThreadgroups = MTLSize(width: (width + 15) / 16, height: (height + 15) / 16, depth: 1)
        commandEncoder.dispatchThreadgroups(numThreadgroups, threadsPerThreadgroup: threadsPerGroup)

        // Завершение
        commandEncoder.endEncoding()
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()

        return outputTexture
    }

    public func eraseBackground(
        from image: CGImage,
        maskImage: CGImage,
        rotated: Bool
    ) -> CVPixelBuffer? {
        let width = image.width
        let height = image.height
        // Создаем выходную текстуру
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .rgba8Unorm,
            width: width,
            height: height,
            mipmapped: false
        )
        descriptor.usage = [.shaderWrite, .shaderRead]
        let outputTexture = device.makeTexture(descriptor: descriptor)!

        let textureLoader = MTKTextureLoader(device: device)
        guard let originalTexture = try? textureLoader.newTexture(cgImage: image),
              let maskTexture = try? textureLoader.newTexture(cgImage: maskImage)
        else { return nil }

        // Обработка
        let commandBuffer = commandQueue.makeCommandBuffer()!
        let commandEncoder = commandBuffer.makeComputeCommandEncoder()!
        commandEncoder.setComputePipelineState(pipelineState)
        commandEncoder.setTexture(originalTexture, index: 0)
        commandEncoder.setTexture(maskTexture, index: 1)
        commandEncoder.setTexture(outputTexture, index: 2)

        var renderParams = RenderParameters(convertToBGRA: true, shouldRotate: rotated)
        let renderParamsBuffer = device.makeBuffer(bytes: &renderParams, length: MemoryLayout<RenderParameters>.size, options: [])
        commandEncoder.setBuffer(renderParamsBuffer, offset: 0, index: 0)

        // Запуск шейдера
        let threadsPerGroup = MTLSize(width: 16, height: 16, depth: 1)
        let numThreadgroups = MTLSize(width: (width + 15) / 16, height: (height + 15) / 16, depth: 1)
        commandEncoder.dispatchThreadgroups(numThreadgroups, threadsPerThreadgroup: threadsPerGroup)

        // Завершение
        commandEncoder.endEncoding()
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()

        var pixelBuffer: CVPixelBuffer?
        guard convert(texture: outputTexture, toPixelBufferOut: &pixelBuffer) else {
            fatalError()
        }
        return pixelBuffer?.rotate90PixelBuffer(factor: 3)
    }

    func convert(texture: MTLTexture, toPixelBufferOut pixelBufferOut: inout CVPixelBuffer?) -> Bool {
        let width = texture.width
        let height = texture.height
        let pixelFormat = kCVPixelFormatType_32BGRA // Пример формата, может отличаться в зависимости от вашего MTLTexture

        let attributes: [CFString: Any] = [
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue!,
            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue!,
            kCVPixelBufferMetalCompatibilityKey: kCFBooleanTrue!,
        ]

        let status = CVPixelBufferCreate(nil, width, height, pixelFormat, attributes as CFDictionary, &pixelBufferOut)

        guard status == kCVReturnSuccess, let pixelBuffer = pixelBufferOut else {
            return false
        }

        CVPixelBufferLockBaseAddress(pixelBuffer, [])
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let encoder = commandBuffer.makeBlitCommandEncoder(),
              let textureBuffer = device.makeBuffer(length: bytesPerRow * height, options: .storageModeShared),
              let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer) else {
            CVPixelBufferUnlockBaseAddress(pixelBuffer, [])
            return false
        }

        encoder.copy(
            from: texture,
            sourceSlice: 0,
            sourceLevel: 0,
            sourceOrigin: MTLOrigin(x: 0, y: 0, z: 0),
            sourceSize: MTLSize(width: width, height: height, depth: 1),
            to: textureBuffer,
            destinationOffset: 0,
            destinationBytesPerRow: bytesPerRow,
            destinationBytesPerImage: bytesPerRow * height
        )

        encoder.endEncoding()
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()

        // Копируем данные из textureBuffer в CVPixelBuffer
        let data = textureBuffer.contents()
        memcpy(baseAddress, data, size_t(bytesPerRow * height))

        CVPixelBufferUnlockBaseAddress(pixelBuffer, [])

        return true
    }

}
