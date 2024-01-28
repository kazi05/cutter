//
//  VideoEditorState.swift
//  Cutter
//
//  Created by Гаджиев Казим on 28.01.2024.
//

import SwiftUI

final class VideoEditorState: ObservableObject {
    @Published var isVideoPlaying: Bool = false
    @Published var isEraseEnabled: Bool = false
}
