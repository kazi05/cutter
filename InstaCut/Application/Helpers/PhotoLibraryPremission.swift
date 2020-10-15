//
//  PhotoLibraryPremission.swift
//  InstaCut
//
//  Created by Kazim Gadjiev on 12.10.2020.
//  Copyright © 2020 Kazim Gajiev. All rights reserved.
//

import Photos

class PhotoLibraryPremission {
    private let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
    
    func getPhotolibraryAccesStatus(completion: @escaping (PhotoAuthorizationStatus) -> Void) {
        switch photoAuthorizationStatus {
        case .authorized:
            completion(.success)
            
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({
                (newStatus) in
                print("status is \(newStatus.rawValue)")
                if newStatus ==  PHAuthorizationStatus.authorized {
                    completion(.success)
                } else {
                    completion(.error(.rejected))
                }
            })
            
        case .restricted:
            completion(.error(.rejected))
            
        case .denied:
            completion(.error(.rejected))
            
        default:
            completion(.error(.unknown))
      }
    }
    
}

enum PhotoAuthorizationStatus {
    case success
    case error(PhotoAuthorizationError)
}

enum PhotoAuthorizationError: Error {
    case rejected, unknown, empty
}

extension PhotoAuthorizationError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .rejected:
            return .localized("PH_REJECTED")
            
        case .unknown:
            return .localized("PH_UNKNOWN")
            
        case .empty:
            return .localized("PH_ZERO_COUNT")
        }
    }
}
