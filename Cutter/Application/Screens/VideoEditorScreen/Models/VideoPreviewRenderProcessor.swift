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
//        commandEncoder.setTexture(frame, index: 0)
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
//
//    public func resizeFrame(_ frame: MTLTexture, to size: CGSize) -> CVPixelBuffer? {
//        let descriptor = MTLTextureDescriptor.texture2DDescriptor(
//            pixelFormat: .rgba8Unorm,
//            width: Int(size.width),
//            height: Int(size.height),
//            mipmapped: false
//        )
//        descriptor.usage = [.shaderWrite, .shaderRead]
//        let outputTexture = device.makeTexture(descriptor: descriptor)!
//
//        // Выполнение шейдера
//        let commandBuffer = commandQueue.makeCommandBuffer()!
//        let commandEncoder = commandBuffer.makeComputeCommandEncoder()!
//        commandEncoder.setComputePipelineState(resizePipelineState)
//        commandEncoder.setTexture(frame, index: 0) // Исходная текстура
//        commandEncoder.setTexture(outputTexture, index: 1) // Выходная текстура
//        let threadGroupCount = MTLSizeMake(16, 16, 1)
//        let threadGroups = MTLSizeMake(outputTexture.width / threadGroupCount.width,
//                                       outputTexture.height / threadGroupCount.height,
//                                       1)
//
//        commandEncoder.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadGroupCount)
//        commandEncoder.endEncoding()
//        commandBuffer.commit()
//        commandBuffer.waitUntilCompleted()
//
//        return createCVPixelBuffer(from: outputTexture)
//    }

//    private func createCVPixelBuffer(from texture: MTLTexture) -> CVPixelBuffer? {
//        let ciImage = CIImage(mtlTexture: texture, options: nil)
//        let context = CIContext(mtlDevice: device)
//
//        // Создание CVPixelBuffer для рендеринга
//        var pixelBuffer: CVPixelBuffer?
//        CVPixelBufferCreate(nil, texture.width, texture.height, kCVPixelFormatType_32BGRA, nil, &pixelBuffer)
//
//        // Проверка успешности создания CVPixelBuffer
//        guard let outputPixelBuffer = pixelBuffer else {
//            return nil
//        }
//
//        // Рендеринг CIImage в CVPixelBuffer
//        context.render(ciImage!, to: outputPixelBuffer)
//
//        return outputPixelBuffer
//    }
//
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
//
//    func resizePixelBuffer(_ pixelBuffer: CVPixelBuffer, to size: CGSize) -> CVPixelBuffer? {
//        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
//
//        let filter = CIFilter(name: "CILanczosScaleTransform")!
//        filter.setValue(ciImage, forKey: kCIInputImageKey)
//        filter.setValue(size.height / ciImage.extent.height, forKey: kCIInputScaleKey)
//        filter.setValue(1.0, forKey: kCIInputAspectRatioKey)
//        guard let outputCIImage = filter.outputImage else { return nil }
//
//        let context = CIContext()
//
//        var newPixelBuffer: CVPixelBuffer?
//        CVPixelBufferCreate(nil, Int(size.width), Int(size.height), CVPixelBufferGetPixelFormatType(pixelBuffer), nil, &newPixelBuffer)
//
//        if let newPixelBuffer = newPixelBuffer {
//            context.render(outputCIImage, to: newPixelBuffer)
//            return newPixelBuffer
//        }
//
//        return nil
//    }
}
