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

//    public func eraseBackground(from frame: MTLTexture, mask: CVPixelBuffer) -> MTLTexture? {
//        guard let textureCache,
//              let maskTexture = createTexture(from: mask, textureCache: textureCache)
//        else {
//            print("Не удалось создать MTLTexture из CVPixelBuffer")
//            return nil
//        }
//        let width = frame.width
//        let height = frame.height
//        // Создаем выходную текстуру
//        let descriptor = MTLTextureDescriptor.texture2DDescriptor(
//            pixelFormat: .rgba8Unorm,
//            width: width,
//            height: height,
//            mipmapped: false
//        )
//        descriptor.usage = [.shaderWrite, .shaderRead]
//        let outputTexture = device.makeTexture(descriptor: descriptor)
//
//        // Обработка
//        let commandBuffer = commandQueue.makeCommandBuffer()!
//        let commandEncoder = commandBuffer.makeComputeCommandEncoder()!
//        commandEncoder.setComputePipelineState(pipelineState)
//        commandEncoder.setTexture(originalTexture, index: 0)
//        commandEncoder.setTexture(maskTexture, index: 1)
//        commandEncoder.setTexture(outputTexture, index: 2)
//
//        // Запуск шейдера
//        let threadsPerGroup = MTLSize(width: 16, height: 16, depth: 1)
//        let numThreadgroups = MTLSize(width: (width + 15) / 16, height: (height + 15) / 16, depth: 1)
//        commandEncoder.dispatchThreadgroups(numThreadgroups, threadsPerThreadgroup: threadsPerGroup)
//
//        // Завершение
//        commandEncoder.endEncoding()
//        commandBuffer.commit()
//        commandBuffer.waitUntilCompleted()
//
//        return outputTexture
//    }

    func createTexture(from pixelBuffer: CVPixelBuffer, textureCache: CVMetalTextureCache) -> MTLTexture? {
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let pixelFormat: MTLPixelFormat = .bgra8Unorm
        
        var cvMetalTexture: CVMetalTexture?
        let status = CVMetalTextureCacheCreateTextureFromImage(
            nil,
            textureCache,
            pixelBuffer,
            nil,
            pixelFormat,
            width,
            height,
            0,
            &cvMetalTexture
        )
        
        guard status == kCVReturnSuccess, let unwrappedCVMetalTexture = cvMetalTexture else {
            return nil
        }

        return CVMetalTextureGetTexture(unwrappedCVMetalTexture)
    }
}
