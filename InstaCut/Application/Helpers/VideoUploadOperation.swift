//
//  VideoUploadOperation.swift
//  InstaCut
//
//  Created by Kazim Gadjiev on 15.10.2020.
//  Copyright © 2020 Kazim Gajiev. All rights reserved.
//

import AVFoundation

class VideoUploadOperation: Operation {
    
    private let asset: AVAsset
    private let timeRange: CMTimeRange
    private let progress: (Float) -> Void
    
    private let fileManager = FileManager.default
    private var exportSession: AVAssetExportSession!
    private let photoLibraryManager: PhotoLibraryManagerType = PhotoLibraryManager()
    private var timer: Timer!
    
    init(with asset: AVAsset, range: CMTimeRange, progress: @escaping (Float) -> Void) {
        self.asset = asset
        self.timeRange = range
        self.progress = progress
        super.init()
    }
    
    override func main() {
        if isCancelled { return }
        
        saveVideoToPhotoAlbum()
    }
    
    override func cancel() {
        exportSession.cancelExport()
    }
    
    private func saveVideoToPhotoAlbum() {
        
        guard let outputURL = createDirectory() else { return }
        
        if isCancelled { return }
        
        exportToCameraRoll(to: outputURL)
    }
    
    private func createDirectory() -> URL? {
        
        guard let documentDirectory = try? fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else { return nil }
            
        var outputURL = documentDirectory.appendingPathComponent("output")
        do {
            let name = "outputVideo__\(Int(Date().timeIntervalSince1970))"
            outputURL = outputURL.appendingPathComponent("\(name).mov")
            try fileManager.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print(error)
        }
        
        return outputURL
    }
    
    private func removeFileFromDirectory(outputURL: URL) {
        try? fileManager.removeItem(at: outputURL)
    }
    
    private func exportToCameraRoll(to outputURL: URL) {
        guard let session = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else {return}
        
        if isCancelled { return }
        
        exportSession = session
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileType.mov
        exportSession.timeRange = timeRange
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { [weak self] (_) in
            self?.observeExportProgress()
        })
        
        exportSession.exportAsynchronously { [weak self] in
            guard let self = self else { return }
            switch self.exportSession.status {
            case .completed:
                self.invalidateTimer()
                print("exported at \(outputURL)")
                self.photoLibraryManager.saveVideoToPhotoLibrary(from: outputURL) { (result) in
                    switch result {
                    case .failure(let error):
                        print(error.localizedDescription)
                        
                    case .success(let saved):
                        if saved {
                            self.removeFileFromDirectory(outputURL: outputURL)
                            self.completionBlock?()
                        } else {
                            print("Something wrong")
                        }
                    }
                }
            case .failed:
                print("failed \(String(describing: self.exportSession.error))")
                self.invalidateTimer()
            case .cancelled:
                print("cancelled \(String(describing: self.exportSession.error))")
                self.invalidateTimer()
            default: break
            }
        }
    }
    
    private func observeExportProgress() {
        progress(exportSession.progress)
    }
    
    private func invalidateTimer() {
        timer.invalidate()
        timer = nil
    }
}
