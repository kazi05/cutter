//
//  ContentDetailsScreen.swift
//  Cutter
//
//  Created by Гаджиев Казим on 28.12.2023.
//

import SwiftUI

struct ContentDetailsScreen: View {
    @EnvironmentObject var navigationStateManager: AppNavigationStateManager
    
    var body: some View {
        if let state = navigationStateManager.selectionState {
            switch state {
            case .videoEditing(let videoModel):
                VideoEditorScreen(video: videoModel)
            }
        } else {
            Text("DETAILS_PICK_VIDEO")
        }
    }
}

#Preview {
    ContentDetailsScreen()
        .environmentObject(AppNavigationStateManager())
}
