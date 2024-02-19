//
//  CVPixelBuffer.swift
//  Cutter
//
//  Created by Гаджиев Казим on 18.02.2024.
//

import UIKit
import Accelerate
import CoreImage

extension CVPixelBuffer {
    func toCGImage() -> CGImage {
        let ciImage = CIImage(cvPixelBuffer: self)
        let context = CIContext(options: nil)
        return context.createCGImage(ciImage, from: CGRect(x: 0,y: 0,width: CVPixelBufferGetWidth(self),height: CVPixelBufferGetHeight(self)))!
    }

    func toBGRApixelBuffer() -> CVPixelBuffer? {
        let width = CVPixelBufferGetWidth(self)
        let height = CVPixelBufferGetHeight(self)
        let frameSize = CGSize(width: width, height: height)

        var pixelBuffer:CVPixelBuffer? = nil
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            Int(frameSize.width),
            Int(frameSize.height),
            kCVPixelFormatType_32BGRA,
            nil,
            &pixelBuffer
        )
        if status != kCVReturnSuccess {
            return nil
        }

        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags.init(rawValue: 0))
        let data = CVPixelBufferGetBaseAddress(pixelBuffer!)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue)
        let context = CGContext(
            data: data,
            width: Int(frameSize.width),
            height: Int(frameSize.height),
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!),
            space: rgbColorSpace,
            bitmapInfo: bitmapInfo.rawValue
        )
        context!.draw(self.toCGImage(), in: CGRect(x: 0, y: 0, width: width, height: height))
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))

        return pixelBuffer
    }

    /**
      First crops the pixel buffer, then resizes it.

      This function requires the caller to pass in both the source and destination
      pixel buffers. The dimensions of destination pixel buffer should be at least
      `scaleWidth` x `scaleHeight` pixels.
    */
    public func resizePixelBuffer(from srcPixelBuffer: CVPixelBuffer,
                                  to dstPixelBuffer: CVPixelBuffer,
                                  cropX: Int,
                                  cropY: Int,
                                  cropWidth: Int,
                                  cropHeight: Int,
                                  scaleWidth: Int,
                                  scaleHeight: Int) {

      assert(CVPixelBufferGetWidth(dstPixelBuffer) >= scaleWidth)
      assert(CVPixelBufferGetHeight(dstPixelBuffer) >= scaleHeight)

      let srcFlags = CVPixelBufferLockFlags.readOnly
      let dstFlags = CVPixelBufferLockFlags(rawValue: 0)

      guard kCVReturnSuccess == CVPixelBufferLockBaseAddress(srcPixelBuffer, srcFlags) else {
        print("Error: could not lock source pixel buffer")
        return
      }
      defer { CVPixelBufferUnlockBaseAddress(srcPixelBuffer, srcFlags) }

      guard kCVReturnSuccess == CVPixelBufferLockBaseAddress(dstPixelBuffer, dstFlags) else {
        print("Error: could not lock destination pixel buffer")
        return
      }
      defer { CVPixelBufferUnlockBaseAddress(dstPixelBuffer, dstFlags) }

      guard let srcData = CVPixelBufferGetBaseAddress(srcPixelBuffer),
            let dstData = CVPixelBufferGetBaseAddress(dstPixelBuffer) else {
        print("Error: could not get pixel buffer base address")
        return
      }

      let srcBytesPerRow = CVPixelBufferGetBytesPerRow(srcPixelBuffer)
      let offset = cropY*srcBytesPerRow + cropX*4
      var srcBuffer = vImage_Buffer(data: srcData.advanced(by: offset),
                                    height: vImagePixelCount(cropHeight),
                                    width: vImagePixelCount(cropWidth),
                                    rowBytes: srcBytesPerRow)

      let dstBytesPerRow = CVPixelBufferGetBytesPerRow(dstPixelBuffer)
      var dstBuffer = vImage_Buffer(data: dstData,
                                    height: vImagePixelCount(scaleHeight),
                                    width: vImagePixelCount(scaleWidth),
                                    rowBytes: dstBytesPerRow)

      let error = vImageScale_ARGB8888(&srcBuffer, &dstBuffer, nil, vImage_Flags(0))
      if error != kvImageNoError {
        print("Error:", error)
      }
    }

    /**
      First crops the pixel buffer, then resizes it.

      This allocates a new destination pixel buffer that is Metal-compatible.
    */
    public func resizePixelBuffer(_ srcPixelBuffer: CVPixelBuffer,
                                  cropX: Int,
                                  cropY: Int,
                                  cropWidth: Int,
                                  cropHeight: Int,
                                  scaleWidth: Int,
                                  scaleHeight: Int) -> CVPixelBuffer? {

      let pixelFormat = CVPixelBufferGetPixelFormatType(srcPixelBuffer)
      let dstPixelBuffer = createPixelBuffer(width: scaleWidth, height: scaleHeight,
                                             pixelFormat: pixelFormat)

      if let dstPixelBuffer = dstPixelBuffer {
        CVBufferPropagateAttachments(srcPixelBuffer, dstPixelBuffer)

        resizePixelBuffer(from: srcPixelBuffer, to: dstPixelBuffer,
                          cropX: cropX, cropY: cropY,
                          cropWidth: cropWidth, cropHeight: cropHeight,
                          scaleWidth: scaleWidth, scaleHeight: scaleHeight)
      }

      return dstPixelBuffer
    }

    /**
      Resizes a CVPixelBuffer to a new width and height.

      This function requires the caller to pass in both the source and destination
      pixel buffers. The dimensions of destination pixel buffer should be at least
      `width` x `height` pixels.
    */
    public func resizePixelBuffer(from srcPixelBuffer: CVPixelBuffer,
                                  to dstPixelBuffer: CVPixelBuffer,
                                  width: Int, height: Int) {
      resizePixelBuffer(from: srcPixelBuffer, to: dstPixelBuffer,
                        cropX: 0, cropY: 0,
                        cropWidth: CVPixelBufferGetWidth(srcPixelBuffer),
                        cropHeight: CVPixelBufferGetHeight(srcPixelBuffer),
                        scaleWidth: width, scaleHeight: height)
    }

    /**
      Resizes a CVPixelBuffer to a new width and height.

      This allocates a new destination pixel buffer that is Metal-compatible.
    */
    public func resizePixelBuffer(width: Int, height: Int) -> CVPixelBuffer? {
      return resizePixelBuffer(self, cropX: 0, cropY: 0,
                               cropWidth: CVPixelBufferGetWidth(self),
                               cropHeight: CVPixelBufferGetHeight(self),
                               scaleWidth: width, scaleHeight: height)
    }

    /**
      Resizes a CVPixelBuffer to a new width and height, using Core Image.
    */
    public func resizePixelBuffer(_ pixelBuffer: CVPixelBuffer,
                                  width: Int, height: Int,
                                  output: CVPixelBuffer, context: CIContext) {
      let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
      let sx = CGFloat(width) / CGFloat(CVPixelBufferGetWidth(pixelBuffer))
      let sy = CGFloat(height) / CGFloat(CVPixelBufferGetHeight(pixelBuffer))
      let scaleTransform = CGAffineTransform(scaleX: sx, y: sy)
      let scaledImage = ciImage.transformed(by: scaleTransform)
      context.render(scaledImage, to: output)
    }
    
    fileprivate func metalCompatiblityAttributes() -> [String: Any] {
      let attributes: [String: Any] = [
        String(kCVPixelBufferMetalCompatibilityKey): true,
        String(kCVPixelBufferOpenGLCompatibilityKey): true,
        String(kCVPixelBufferIOSurfacePropertiesKey): [
          String(kCVPixelBufferIOSurfaceOpenGLESTextureCompatibilityKey): true,
          String(kCVPixelBufferIOSurfaceOpenGLESFBOCompatibilityKey): true,
          String(kCVPixelBufferIOSurfaceCoreAnimationCompatibilityKey): true
        ]
      ]
      return attributes
    }

    /**
      Creates a pixel buffer of the specified width, height, and pixel format.

      - Note: This pixel buffer is backed by an IOSurface and therefore can be
        turned into a Metal texture.
    */
    public func createPixelBuffer(width: Int, height: Int, pixelFormat: OSType) -> CVPixelBuffer? {
      let attributes = metalCompatiblityAttributes() as CFDictionary
      var pixelBuffer: CVPixelBuffer?
      let status = CVPixelBufferCreate(nil, width, height, pixelFormat, attributes, &pixelBuffer)
      if status != kCVReturnSuccess {
        print("Error: could not create pixel buffer", status)
        return nil
      }
      return pixelBuffer
    }

    /**
      Creates a RGB pixel buffer of the specified width and height.
    */
    public func createPixelBuffer(width: Int, height: Int) -> CVPixelBuffer? {
      createPixelBuffer(width: width, height: height, pixelFormat: kCVPixelFormatType_32BGRA)
    }

    /**
      Rotates a CVPixelBuffer by the provided factor of 90 counterclock-wise.

      This function requires the caller to pass in both the source and destination
      pixel buffers. The width and height of destination pixel buffer should be the
      opposite of the source's dimensions if rotating by 90 or 270 degrees.
    */
    public func rotate90PixelBuffer(from srcPixelBuffer: CVPixelBuffer,
                                    to dstPixelBuffer: CVPixelBuffer,
                                    factor: UInt8) {
      let srcFlags = CVPixelBufferLockFlags.readOnly
      let dstFlags = CVPixelBufferLockFlags(rawValue: 0)

      guard kCVReturnSuccess == CVPixelBufferLockBaseAddress(srcPixelBuffer, srcFlags) else {
        print("Error: could not lock source pixel buffer")
        return
      }
      defer { CVPixelBufferUnlockBaseAddress(srcPixelBuffer, srcFlags) }

      guard kCVReturnSuccess == CVPixelBufferLockBaseAddress(dstPixelBuffer, dstFlags) else {
        print("Error: could not lock destination pixel buffer")
        return
      }
      defer { CVPixelBufferUnlockBaseAddress(dstPixelBuffer, dstFlags) }

      guard let srcData = CVPixelBufferGetBaseAddress(srcPixelBuffer),
            let dstData = CVPixelBufferGetBaseAddress(dstPixelBuffer) else {
        print("Error: could not get pixel buffer base address")
        return
      }

      let srcWidth = CVPixelBufferGetWidth(srcPixelBuffer)
      let srcHeight = CVPixelBufferGetHeight(srcPixelBuffer)

      let srcBytesPerRow = CVPixelBufferGetBytesPerRow(srcPixelBuffer)
      var srcBuffer = vImage_Buffer(data: srcData,
                                    height: vImagePixelCount(srcHeight),
                                    width: vImagePixelCount(srcWidth),
                                    rowBytes: srcBytesPerRow)

      let dstWidth = CVPixelBufferGetWidth(dstPixelBuffer)
      let dstHeight = CVPixelBufferGetHeight(dstPixelBuffer)
      let dstBytesPerRow = CVPixelBufferGetBytesPerRow(dstPixelBuffer)
      var dstBuffer = vImage_Buffer(data: dstData,
                                    height: vImagePixelCount(dstHeight),
                                    width: vImagePixelCount(dstWidth),
                                    rowBytes: dstBytesPerRow)

      var color = UInt8(0)
      let error = vImageRotate90_ARGB8888(&srcBuffer, &dstBuffer, factor, &color, vImage_Flags(0))
      if error != kvImageNoError {
        print("Error:", error)
      }
    }

    /**
      Rotates a CVPixelBuffer by the provided factor of 90 counterclock-wise.

      This allocates a new destination pixel buffer that is Metal-compatible.
    */
    public func rotate90PixelBuffer(factor: UInt8) -> CVPixelBuffer? {
      var dstWidth = CVPixelBufferGetWidth(self)
      var dstHeight = CVPixelBufferGetHeight(self)
      if factor % 2 == 1 {
        swap(&dstWidth, &dstHeight)
      }

      let pixelFormat = CVPixelBufferGetPixelFormatType(self)
      let dstPixelBuffer = createPixelBuffer(width: dstWidth, height: dstHeight, pixelFormat: pixelFormat)

      if let dstPixelBuffer = dstPixelBuffer {
        CVBufferPropagateAttachments(self, dstPixelBuffer)
        rotate90PixelBuffer(from: self, to: dstPixelBuffer, factor: factor)
      }
      return dstPixelBuffer
    }
}
