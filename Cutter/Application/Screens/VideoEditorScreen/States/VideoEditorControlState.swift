//
//  VideoPreviewControlState.swift
//  Cutter
//
//  Created by Гаджиев Казим on 28.01.2024.
//

import SwiftUI
import Combine

final class VideoEditorControlState: ObservableObject {
    @Published private(set) var leftOptions: [VideoEditorControlItem.Option]
    @Published private(set) var centerItems: [VideoEditorControlItem.Interaction]
    @Published private(set) var rightOptions: [VideoEditorControlItem.Option]
    @Published private(set) var selectedOption: VideoEditorControlItem.Option?
    
    let optionChangeAccepted = PassthroughSubject<VideoEditorControlItem.Option, Never>()
    let onItemInteracted = PassthroughSubject<VideoEditorControlItem.Interaction, Never>()

    var subscriptions = Set<AnyCancellable>()

    private let initialLeftOptions: [VideoEditorControlItem.Option] = []
    private let initialCenterItems: [VideoEditorControlItem.Interaction] = [.playPause]
    private let initialRightOptions: [VideoEditorControlItem.Option] = [
        .eraseBackground
    ]
    
    init() {
        self.leftOptions = initialLeftOptions
        self.centerItems = initialCenterItems
        self.rightOptions = initialRightOptions
    }

    deinit {
        subscriptions.forEach { $0.cancel() }
        subscriptions.removeAll()
    }

    func optionChoosed(_ option: VideoEditorControlItem.Option) {
        switch option {
        case .cancelEditing:
            selectedOption = nil
            setInitialItems()
        case .acceptEditing:
            if let option = selectedOption {
                optionChangeAccepted.send(option)
            }
            selectedOption = nil
            setInitialItems()
        default:
            selectedOption = option
            leftOptions = [.cancelEditing]
            rightOptions = [.acceptEditing]
        }
        switch option {
        case .eraseBackground:
            centerItems.append(.enableDisable)
        default:
            break
        }
    }
    
    func itemInteracted(_ item: VideoEditorControlItem.Interaction) {
        onItemInteracted.send(item)
    }
}

fileprivate extension VideoEditorControlState {
    func setInitialItems() {
        leftOptions = initialLeftOptions
        centerItems = initialCenterItems
        rightOptions = initialRightOptions
    }
}
