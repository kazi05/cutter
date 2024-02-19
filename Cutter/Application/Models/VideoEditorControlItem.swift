//
//  VideoPreviewControlItem.swift
//  Cutter
//
//  Created by Гаджиев Казим on 28.01.2024.
//

import SwiftUI

enum VideoEditorControlItem {
    enum Interaction {
        case playPause
        case enableDisable
    }
    enum Option {
        case trimCut
        case separate
        case eraseBackground
        case cancelEditing
        case acceptEditing

        var title: String? {
            switch self {
            case .trimCut:
                return "TRIM_OPTION_TITLE"
            case .separate:
                return "SEPARATE_OPTION_TITLE"
            case .eraseBackground:
                return "ERASE_BACKGROUND_OPTION_TITLE"
            default:
                return nil
            }
        }
    }
}
