//
//  RVMPredictor.swift
//  Cutter
//
//  Created by Гаджиев Казим on 18.02.2024.
//

import CoreML
import Vision
import CoreImage
import UIKit

protocol RVMPredictable {
    var inputWidth: Int { get }
    var inputHeight: Int { get }
    mutating func predict(src: CVPixelBuffer) -> (CVPixelBuffer, CVPixelBuffer)
}

// TODO: Refactor

struct RVMPredictorHD: RVMPredictable {
    private let model: RVM_HD = {
        do {
            return try RVM_HD(configuration:  MLModelConfiguration())
        } catch {
            print(error)
            fatalError("can't create model")
        }
    }()

    let inputWidth: Int = 1280
    let inputHeight: Int = 720

    private var r1: MLMultiArray?
    private var r2: MLMultiArray?
    private var r3: MLMultiArray?
    private var r4: MLMultiArray?

    mutating func predict(src: CVPixelBuffer) -> (CVPixelBuffer, CVPixelBuffer) {
        let modelInput = RVM_HDInput(src: src, r1i: r1, r2i: r2, r3i: r3, r4i: r4)

        let modelOutput = try! model.prediction(input: modelInput)

        r1 = modelOutput.r1o
        r2 = modelOutput.r2o
        r3 = modelOutput.r3o
        r4 = modelOutput.r4o
        let fgrPixel = modelOutput.fgr
        let phaPixel = modelOutput.pha
        return (fgrPixel, phaPixel)
    }
}

struct RVMPredictorFHD: RVMPredictable {
    private let model: RVM_FHD = {
        do {
            return try RVM_FHD(configuration:  MLModelConfiguration())
        } catch {
            print(error)
            fatalError("can't create model")
        }
    }()

    let inputWidth: Int = 1920
    let inputHeight: Int = 1080

    private var r1: MLMultiArray?
    private var r2: MLMultiArray?
    private var r3: MLMultiArray?
    private var r4: MLMultiArray?

    mutating func predict(src: CVPixelBuffer) -> (CVPixelBuffer, CVPixelBuffer) {
        let modelInput = RVM_FHDInput(src: src, r1i: r1, r2i: r2, r3i: r3, r4i: r4)

        let modelOutput = try! model.prediction(input: modelInput)

        r1 = modelOutput.r1o
        r2 = modelOutput.r2o
        r3 = modelOutput.r3o
        r4 = modelOutput.r4o
        let fgrPixel = modelOutput.fgr
        let phaPixel = modelOutput.pha
        return (fgrPixel, phaPixel)
    }
}
