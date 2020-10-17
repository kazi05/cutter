//
//  VideoUploadOperation.swift
//  InstaCut
//
//  Created by Kazim Gadjiev on 15.10.2020.
//  Copyright © 2020 Kazim Gajiev. All rights reserved.
//

import AVFoundation

class VideoUploadOperation: AsyncOperation {
    
    // MARK: - Private properties 🕶
    private let asset: AVAsset
    private let timeRange: CMTimeRange
    private let progress: (Float) -> Void
    
    private let fileManager = FileManager.default
    private var exportSession: AVAssetExportSession!
    private let photoLibraryManager: PhotoLibraryManagerType = PhotoLibraryManager()
    
    override var isAsynchronous: Bool {
        return true
    }
    
    // MARK: - LifeCycle 🌎
    init(with asset: AVAsset, range: CMTimeRange, progress: @escaping (Float) -> Void) {
        self.asset = asset
        self.timeRange = range
        self.progress = progress
    }
    
    override func main() {
        super.main()
        saveVideoToPhotoAlbum()
    }
    
    override func cancel() {
        super.cancel()
        if exportSession != nil {
            exportSession.cancelExport()
        }
    }
    
}

// MARK: - Export methods
fileprivate extension VideoUploadOperation {
    
    func saveVideoToPhotoAlbum() {
        
        guard let outputURL = createDirectory(), !isCancelled else { return }
        
        if isCancelled { return }
        
        exportToCameraRoll(to: outputURL)
    }
    
    func createDirectory() -> URL? {
        
        guard let documentDirectory = try? fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else { return nil }
        
        var outputURL = documentDirectory.appendingPathComponent("output")
        do {
            let name = "outputVideo__\(Int(timeRange.start.seconds))"
            outputURL = outputURL.appendingPathComponent("\(name).mov")
            try fileManager.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("File create error: \(error.localizedDescription)")
        }
        
        return outputURL
    }
    
    func removeFileFromDirectory(outputURL: URL) {
        try? fileManager.removeItem(at: outputURL)
    }
    
    func exportToCameraRoll(to outputURL: URL) {
        let videoMaker = VideoCompositionMaker(asset: asset)
        
        guard let composition = videoMaker.generateComposition(with: timeRange),
              let session = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)
        else { return }
        
        if isCancelled { return }
        
        exportSession = session
        exportSession.videoComposition = videoMaker.videoComposition
        exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileType.mov
        
        removeFileFromDirectory(outputURL: outputURL)
        
        exportSession.exportAsynchronously { [weak self] in
            guard let self = self else { return }
            
            switch self.exportSession.status {
            case .completed:
                self.photoLibraryManager.saveVideoToPhotoLibrary(from: outputURL) { (result) in
                    switch result {
                    case .failure(let error):
                        print("Save to camera roll error: \(error.localizedDescription)")

                    case .success(let saved):
                        if saved {
                            print("Saved")
                            self.removeFileFromDirectory(outputURL: outputURL)
                            self.state = .finished
                        } else {
                            print("Something wrong")
                        }
                    }
                }
            case .failed:
                print("failed \(String(describing: self.exportSession.error))")
                self.state = .finished
            case .cancelled:
                print("cancelled \(String(describing: self.exportSession.error))")
                self.state = .cancelled
            default: break
            }
        }
        
        repeat {
            Thread.sleep(forTimeInterval: 0.2)
            observeExportProgress()
        } while exportSession.status == .exporting
    }
    
    @objc func observeExportProgress() {
        print("Progress: \(exportSession.progress)")
        guard exportSession.progress < 1 else { return }
        progress(exportSession.progress)
    }
    
}
