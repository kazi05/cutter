//
//  MetalVideoView.swift
//  Cutter
//
//  Created by Гаджиев Казим on 25.01.2024.
//

import SwiftUI
import MetalKit
import Combine

struct MetalVideoView: UIViewRepresentable {
    let renderer: VideoPreviewRenderer
    var state: VideoPlayerState
    
    private let device: MTLDevice
    private var subscriptions = Set<AnyCancellable>()
    
    init(
        renderer: VideoPreviewRenderer,
        state: VideoPlayerState = .stop,
        device: MTLDevice = MTLCreateSystemDefaultDevice()!
    ) {
        self.renderer = renderer
        self.state = state
        self.device = device
    }
    
    func makeUIView(context: Context) -> MTKView {
        let mtkView = MTKView()
        mtkView.device = device
        mtkView.delegate = context.coordinator
        return mtkView
    }
    
    func updateUIView(_ uiView: MTKView, context: Context) {
        uiView.isPaused = state != .play
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, renderer: renderer)
    }
    
    class Coordinator: NSObject, MTKViewDelegate {
        var parent: MetalVideoView
        var renderer: VideoPreviewRenderer
        var commandQueue: MTLCommandQueue?
        var pipelineState: MTLRenderPipelineState?
        var samplerState: MTLSamplerState?
        
        init(_ parent: MetalVideoView, renderer: VideoPreviewRenderer) {
            self.parent = parent
            self.renderer = renderer
            super.init()
            self.commandQueue = parent.device.makeCommandQueue()
            setupPipelineState()
            setupSamplerState(device: parent.device)
        }
        
        private func setupPipelineState() {
            guard let device = MTLCreateSystemDefaultDevice(),
                  let library = device.makeDefaultLibrary() else { return }
            
            let vertexFunction = library.makeFunction(name: "renderVertex")
            let fragmentFunction = library.makeFunction(name: "renderFragment")
            
            let pipelineDescriptor = MTLRenderPipelineDescriptor()
            pipelineDescriptor.vertexFunction = vertexFunction
            pipelineDescriptor.fragmentFunction = fragmentFunction
            pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
            
            do {
                pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
            } catch let error {
                print("Ошибка при создании pipeline state: \(error)")
            }
        }
        
        private func setupSamplerState(device: MTLDevice) {
            let samplerDescriptor = MTLSamplerDescriptor()
            samplerDescriptor.minFilter = .linear
            samplerDescriptor.magFilter = .linear
            samplerDescriptor.mipFilter = .linear
            samplerDescriptor.sAddressMode = .repeat
            samplerDescriptor.tAddressMode = .repeat
            samplerDescriptor.rAddressMode = .repeat
            samplerDescriptor.normalizedCoordinates = true
            samplerDescriptor.lodMinClamp = 0
            samplerDescriptor.lodMaxClamp = .greatestFiniteMagnitude
            samplerState = device.makeSamplerState(descriptor: samplerDescriptor)
        }
        
        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
            // Обработать изменение размера view
        }
        
        func draw(in view: MTKView) {
            guard let texture = renderer.getCurrentFrameTexture(device: view.device!),
                  let drawable = view.currentDrawable,
                  let commandBuffer = commandQueue?.makeCommandBuffer(),
                  let renderDescriptor = view.currentRenderPassDescriptor,
                  let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderDescriptor),
                  let pipelineState = pipelineState,
                  let samplerState
            else {
                return
            }
            
            commandEncoder.setRenderPipelineState(pipelineState)
            commandEncoder.setFragmentTexture(texture, index: 0)
            commandEncoder.setFragmentSamplerState(samplerState, index: 0)
            commandEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
            commandEncoder.endEncoding()
            commandBuffer.present(drawable)
            commandBuffer.commit()
        }
    }
}
