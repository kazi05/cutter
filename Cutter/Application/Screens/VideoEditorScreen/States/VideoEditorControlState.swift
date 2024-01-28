//
//  VideoPreviewControlState.swift
//  Cutter
//
//  Created by Гаджиев Казим on 28.01.2024.
//

import SwiftUI

final class VideoEditorControlState: ObservableObject {
    @Published private(set) var leftOptions: [VideoEditorControlItem.Option]
    @Published private(set) var centerItems: [VideoEditorControlItem.Interaction]
    @Published private(set) var rightOptions: [VideoEditorControlItem.Option]
    @Published private(set) var selectedItem: VideoEditorControlItem.Option?
    
    var optionChangeAccepted: ((VideoEditorControlItem.Option) -> Void)?
    var onItemInteracted: ((VideoEditorControlItem.Interaction) -> Void)?
    
    private let initialLeftOptions: [VideoEditorControlItem.Option] = []
    private let initialCenterItems: [VideoEditorControlItem.Interaction] = [.playPause]
    private let initialRightOptions: [VideoEditorControlItem.Option] = [
        .trimCut,
        .separate,
        .eraseBackground
    ]
    
    init() {
        self.leftOptions = initialLeftOptions
        self.centerItems = initialCenterItems
        self.rightOptions = initialRightOptions
    }
    
    func optionChoosed(_ option: VideoEditorControlItem.Option) {
        switch option {
        case .cancelEditing:
            selectedItem = nil
            setInitialItems()
        case .acceptEditing:
            selectedItem = nil
            optionChangeAccepted?(option)
            setInitialItems()
        default:
            selectedItem = option
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
        onItemInteracted?(item)
    }
}

fileprivate extension VideoEditorControlState {
    func setInitialItems() {
        leftOptions = initialLeftOptions
        centerItems = initialCenterItems
        rightOptions = initialRightOptions
    }
}
