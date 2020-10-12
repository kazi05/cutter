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
                print("status is \(newStatus)")
                if newStatus ==  PHAuthorizationStatus.authorized {
                    print("success")
                    completion(.success)
                } else {
                    completion(.error(.localized("PH_REJECTED")))
                }
            })
            
        case .restricted:
            completion(.error(.localized("PH_REJECTED")))
            
        case .denied:
            completion(.error(.localized("PH_REJECTED")))
            
        default:
            completion(.error(.localized("PH_UNKNOWN")))
      }
    }
    
}

enum PhotoAuthorizationStatus {
    case success
    case error(String)
}
