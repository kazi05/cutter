//
//  AppNavigationStateManager.swift
//  Cutter
//
//  Created by Гаджиев Казим on 28.12.2023.
//

import SwiftUI
import Combine

final class AppNavigationStateManager: ObservableObject {
    @Published var selectionState: AppNavigationSelectionState? = nil
    
    func openVideoEditing(_ video: VideoModel) {
        selectionState = .videoEditing(video)
    }
    
    var objectWillChangeSequence: AsyncPublisher<Publishers.Buffer<ObservableObjectPublisher>> {
        objectWillChange
            .buffer(size: 1, prefetch: .byRequest, whenFull: .dropOldest)
            .values
    }
}
