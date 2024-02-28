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
        GeometryReader { gr in
            ScrollView {
                switch state.state {
                case .loading:
                    ProgressView()
                        .frame(maxWidth: .infinity)
                case .loaded(let models):
                    if models.isEmpty { emptyView } else { listView(models, size: gr.size) }
                case .error(let error):
                    errorView(error)
                }
            }
            .background(Color.backgorund)
            .navigationTitle("LIBRARY_TITLE")
        }
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
            Text(LocalizedStringResource(stringLiteral: "PH_REJECTED"))
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
    private func listView(_ models: [VideoThumbnail], size: CGSize) -> some View {
        let threeColumnGrid = [
            GridItem(.flexible(), spacing: 4),
            GridItem(.flexible(), spacing: 4),
            GridItem(.flexible(), spacing: 4),
        ]
        LazyVGrid(columns: threeColumnGrid, spacing: 4, pinnedViews: [.sectionFooters], content: {
            Section {
                ForEach(models) { model in
                    LibraryVideoCard(video: model)
                        .onTapGesture {
                            navigationStateManager.openVideoEditing(model)
                        }
                }
                .frame(height: size.width / 3 * 1.60)
                .clipped()
            } footer: {
                BannerView()
            }
        })
        .padding(8)

        List(selection: $navigationStateManager.selectionState, content: {})
            .hidden()
    }
    
    @ViewBuilder
    private func errorView(_ error: MediaAuthorizationError) -> some View {
        VStack {
            Text(LocalizedStringResource(stringLiteral: error.localizedDescription))
                .multilineTextAlignment(.center)
            Button("LIBRARY_RELOAD") {
                print("Reload")
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
    }
}
