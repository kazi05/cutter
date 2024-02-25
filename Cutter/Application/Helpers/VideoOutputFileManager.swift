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

    func getFiles() {
        do {
            let rootFolderURL = try manager.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: false
            )
            let rootItems = try manager.contentsOfDirectory(atPath: rootFolderURL.absoluteString)
            rootItems.forEach { print("Root folder item", $0) }
            let nestedFolderURL = rootFolderURL.appendingPathComponent(folderName)
            let items = try manager.contentsOfDirectory(atPath: nestedFolderURL.absoluteString)
            items.forEach { print($0) }
        } catch {
            print("Ошибка при удалении файла: \(error)")
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
            let items = try manager.contentsOfDirectory(atPath: nestedFolderURL.absoluteString)
            items.forEach { print($0) }
            try manager.removeItem(at: nestedFolderURL)
        } catch {
            print("Ошибка при удалении файла: \(error)")
        }
    }
}
