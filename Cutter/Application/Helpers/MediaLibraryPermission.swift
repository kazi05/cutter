//
//  MediaLibraryPermission.swift
//  Cutter
//
//  Created by Гаджиев Казим on 26.12.2023.
//

import Photos

final class MediaLibraryPremission {
    func getMedialibraryAccesStatus() async -> MediaAuthorizationStatus {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        switch status {
        case .authorized:
            return .success
            
        case .notDetermined:
            let newStatus = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
            if newStatus ==  PHAuthorizationStatus.authorized {
                return .success
            } else {
                return .error(.rejected)
            }
            
        case .restricted:
            return .error(.rejected)
            
        case .denied:
            return .error(.rejected)
            
        default:
            return .error(.unknown)
      }
    }
    
}

enum MediaAuthorizationStatus {
    case success
    case error(MediaAuthorizationError)
}

enum MediaAuthorizationError: Error {
    case rejected, unknown
}

extension MediaAuthorizationError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .rejected:
            return "PH_REJECTED"
            
        case .unknown:
            return "PH_UNKNOWN"
        }
    }
}

