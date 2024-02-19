//
//  LibraryViewModel.swift
//  Cutter
//
//  Created by Гаджиев Казим on 26.12.2023.
//

import SwiftUI
import Dependencies

final class LibraryState: ObservableObject {
    
    enum State {
        case loading
        case loaded([VideoThumbnail])
        case error(MediaAuthorizationError)
    }
    
    @Published var state: State = .loading
    
    // MARK: - Services
    
    @Dependency(\.videoLibraryService) var videoLibraryService
    
    // MARK: - Init
    
    init() {}
}

// MARK: - Internal methods

extension LibraryState {
    func onAppear() {
        fetchVideos()
    }
    
    func fetchVideos() {
        Task { @MainActor in
            let status = await videoLibraryService.getStatus()
            switch status {
            case .error(let error):
                state = .error(error)
            case .success:
                let models = await videoLibraryService.getVideos()
                state = .loaded(models)
            }
        }
    }
}
