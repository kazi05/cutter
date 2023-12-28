//
//  CutterApp.swift
//  Cutter
//
//  Created by Гаджиев Казим on 26.12.2023.
//

import SwiftUI

@main
struct CutterApp: App {
    @StateObject var navigationStateManager = AppNavigationStateManager()
    
    var body: some Scene {
        WindowGroup {
            NavigationSplitView {
                LibraryScreen()
            } detail: {
                ContentDetailsScreen()
            }
            .environmentObject(navigationStateManager)
        }
    }
}
