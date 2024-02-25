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

struct RVMPredictorHD_P: RVMPredictable {
    private let model: RVM_HD_P = {
        do {
            return try RVM_HD_P(configuration:  MLModelConfiguration())
        } catch {
            print(error)
            fatalError("can't create model")
        }
    }()

    let inputWidth: Int = 720
    let inputHeight: Int = 1280

    private var r1: MLMultiArray?
    private var r2: MLMultiArray?
    private var r3: MLMultiArray?
    private var r4: MLMultiArray?

    mutating func predict(src: CVPixelBuffer) -> (CVPixelBuffer, CVPixelBuffer) {
        let modelInput = RVM_HD_PInput(src: src, r1i: r1, r2i: r2, r3i: r3, r4i: r4)

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

struct RVMPredictorFHD_P: RVMPredictable {
    private let model: RVM_FHD_P = {
        do {
            return try RVM_FHD_P(configuration:  MLModelConfiguration())
        } catch {
            print(error)
            fatalError("can't create model")
        }
    }()

    let inputWidth: Int = 1080
    let inputHeight: Int = 1920

    private var r1: MLMultiArray?
    private var r2: MLMultiArray?
    private var r3: MLMultiArray?
    private var r4: MLMultiArray?

    mutating func predict(src: CVPixelBuffer) -> (CVPixelBuffer, CVPixelBuffer) {
        let modelInput = RVM_FHD_PInput(src: src, r1i: r1, r2i: r2, r3i: r3, r4i: r4)

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

struct RVMPredictor4K: RVMPredictable {
    private let model: RVM_4K = {
        do {
            return try RVM_4K(configuration:  MLModelConfiguration())
        } catch {
            print(error)
            fatalError("can't create model")
        }
    }()

    let inputWidth: Int = 3840
    let inputHeight: Int = 2160

    private var r1: MLMultiArray?
    private var r2: MLMultiArray?
    private var r3: MLMultiArray?
    private var r4: MLMultiArray?

    mutating func predict(src: CVPixelBuffer) -> (CVPixelBuffer, CVPixelBuffer) {
        let modelInput = RVM_4KInput(src: src, r1i: r1, r2i: r2, r3i: r3, r4i: r4)

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

struct RVMPredictor4K_P: RVMPredictable {
    private let modelPortait: RVM_4K_P = {
        do {
            return try RVM_4K_P(configuration:  MLModelConfiguration())
        } catch {
            print(error)
            fatalError("can't create model")
        }
    }()

    let inputWidth: Int = 2160
    let inputHeight: Int = 3840

    private var r1: MLMultiArray?
    private var r2: MLMultiArray?
    private var r3: MLMultiArray?
    private var r4: MLMultiArray?

    mutating func predict(src: CVPixelBuffer) -> (CVPixelBuffer, CVPixelBuffer) {
        let modelInput = RVM_4K_PInput(src: src, r1i: r1, r2i: r2, r3i: r3, r4i: r4)

        let modelOutput = try! modelPortait.prediction(input: modelInput)

        r1 = modelOutput.r1o
        r2 = modelOutput.r2o
        r3 = modelOutput.r3o
        r4 = modelOutput.r4o
        let fgrPixel = modelOutput.fgr
        let phaPixel = modelOutput.pha
        return (fgrPixel, phaPixel)
    }
}
