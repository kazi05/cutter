//
//  CutterApp.swift
//  Cutter
//
//  Created by Гаджиев Казим on 26.12.2023.
//

import SwiftUI

@main
struct CutterApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var navigationStateManager = AppNavigationStateManager()
    @StateObject private var videoRenderingStateManager = VideoRenderingStateManager()

    var body: some Scene {
        WindowGroup {
            NavigationSplitView(columnVisibility: .constant(.all)) {
                LibraryScreen()
            } detail: {
                ContentDetailsScreen(videoRenderingStateManager: videoRenderingStateManager)
            }
            .overlay(content: {
                if let progressModel = videoRenderingStateManager.progressModel {
                    VideoRenderProgressView(progressState: progressModel)
                } else {
                    Color.clear
                }
            })
            .environmentObject(navigationStateManager)
        }
    }
}
