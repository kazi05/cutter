//
//  LibraryScreen.swift
//  Cutter
//
//  Created by Гаджиев Казим on 26.12.2023.
//

import SwiftUI
import PhotosUI

struct LibraryScreen: View {
    
    @StateObject private var state = LibraryState()
    @EnvironmentObject private var navigationStateManager: AppNavigationStateManager
    
    var body: some View {
        ScrollView {
            switch state.state {
            case .loading:
                ProgressView()
            case .loaded(let models):
                if models.isEmpty { emptyView } else { listView(models) }
            case .error(let error):
                errorView(error)
            }
        }
        .background(Color.backgorund)
        .navigationTitle("LIBRARY_TITLE")
        .onFirstAppear {
            state.onAppear()
        }
    }
    
    @ViewBuilder
    private var emptyView: some View {
        VStack {
            Text("LIBRARY_EMPTY_LIST")
            Button("LIBRARY_RELOAD") {
                state.fetchVideos()
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
    }
    
    @ViewBuilder
    private var rejectedView: some View {
        VStack(spacing: 10) {
            Text("PH_REJECTED")
                .multilineTextAlignment(.center)
                .foregroundStyle(Color("textColor"))
            Button("LIBRARY_GO_SETTINGS") {
                if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            }
        }
        .padding(.horizontal, 16)
    }
    
    @ViewBuilder
    private func listView(_ models: [VideoModel]) -> some View {
        let threeColumnGrid = [
            GridItem(.flexible(), spacing: 4),
            GridItem(.flexible(), spacing: 4),
            GridItem(.flexible(), spacing: 4),
        ]
        LazyVGrid(columns: threeColumnGrid, spacing: 4, content: {
            ForEach(models) { model in
                LibraryVideoCard(video: model)
                    .onTapGesture {
                        navigationStateManager.openVideoEditing(model)
                    }
            }
            .clipped()
            .aspectRatio(0.60, contentMode: .fit)
        })
        .padding(8)
        
        List(selection: $navigationStateManager.selectionState, content: {})
            .hidden()
    }
    
    @ViewBuilder
    private func errorView(_ error: MediaAuthorizationError) -> some View {
        VStack {
            Text(error.localizedDescription)
            Button("LIBRARY_RELOAD") {
                print("Reload")
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
    }
}
