//
//  PhotoLibraryPremission.swift
//  InstaCut
//
//  Created by Kazim Gajiev on 03/03/2019.
//  Copyright © 2019 Kazim Gajiev. All rights reserved.
//

import Photos

class PhotoLibraryPremission {
    private let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
    
    static let shared = PhotoLibraryPremission()
    private init() {}
    
    func getPhotolibraryAccesStatus(completion: @escaping (PhotoAuthorizationStatus) -> Void) {
        switch photoAuthorizationStatus {
        case .authorized:
            completion(.succes)
            
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({
                (newStatus) in
                print("status is \(newStatus)")
                if newStatus ==  PHAuthorizationStatus.authorized {
                    print("success")
                    completion(.succes)
                } else {
                    completion(.error("Вы не разрешили приложению использовать вашу медиатеку. Для разрешения зайдите в Настройки"))
                }
            })
            
        case .restricted:
            completion(.error("Вы не разрешили приложению использовать вашу медиатеку. Для разрешения зайдите в Настройки"))
            
        case .denied:
            completion(.error("Вы не разрешили приложению использовать вашу медиатеку. Для разрешения зайдите в Настройки"))
            
        @unknown default:
          completion(.error("Unknown error"))
      }
    }
    
}

enum PhotoAuthorizationStatus {
    case succes
    case error(String)
}
