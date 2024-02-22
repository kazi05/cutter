//
//  VideoOutputFileManager.swift
//  Cutter
//
//  Created by Гаджиев Казим on 22.02.2024.
//

import Foundation

final class VideoOutputFileManager {
    static let shared = VideoOutputFileManager()

    private let fileName = "tempProcessedVideo.MOV"
    private var generatedUrl: URL?

    func generateTemporaryURL() -> URL? {
        let tempDirectory = FileManager.default.temporaryDirectory
        let destinationURL = tempDirectory.appendingPathComponent(fileName)
        print(destinationURL.absoluteString, FileManager.default.fileExists(atPath: destinationURL.absoluteString))
        if FileManager.default.fileExists(atPath: destinationURL.absoluteString) {
            deleteFile()
        }
        generatedUrl = destinationURL
        return destinationURL
    }

    func deleteFile() {
        do {
            guard let url = generatedUrl else { return }
            try FileManager.default.removeItem(at: url)
        } catch {
            print("Ошибка при удалении файла: \(error)")
        }
    }
}
