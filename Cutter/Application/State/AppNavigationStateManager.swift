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

    func openVideoEditing(_ video: VideoThumbnail) {
        selectionState = .videoEditing(video)
    }
}
