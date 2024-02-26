//
//  VideoOutputFileManager.swift
//  Cutter
//
//  Created by Гаджиев Казим on 22.02.2024.
//

import Foundation

final class VideoOutputFileManager {
    static let shared = VideoOutputFileManager()
    private let manager = FileManager.default
    private let folderName = "video-outputs"

    func generateTemporaryURL() -> URL? {
        do {
            let rootFolderURL = try manager.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: false
            )

            let nestedFolderURL = rootFolderURL.appendingPathComponent(folderName)

            if !manager.fileExists(atPath: nestedFolderURL.relativePath) {
                try manager.createDirectory(
                    at: nestedFolderURL,
                    withIntermediateDirectories: false,
                    attributes: nil
                )
            }
            let destinationURL = nestedFolderURL.appendingPathComponent("\(UUID().uuidString).MOV")
            return destinationURL
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }

    func deleteFiles() {
        do {
            let rootFolderURL = try manager.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: false
            )

            let nestedFolderURL = rootFolderURL.appendingPathComponent(folderName)
            try manager.removeItem(at: nestedFolderURL)
        } catch {
            print(error.localizedDescription)
        }
    }
}
