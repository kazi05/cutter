//
//  VideoEditorPlayer.swift
//  Cutter
//
//  Created by Гаджиев Казим on 01.01.2024.
//

import SwiftUI
import SafeSFSymbols

struct VideoEditorControls: View {
    @ObservedObject private var state: VideoEditorState
    
    private var controlState: VideoEditorControlState {
        state.controlState
    }

    init(
        state: VideoEditorState
    ) {
        self.state = state
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            HStack(spacing: 8) {
                ForEach(0..<controlState.leftOptions.count, id: \.self) { index in
                    let option = controlState.leftOptions[index]
                    viewForOption(option)
                }
            }
            .frame(maxWidth: .infinity)
            
            VStack(alignment: .center, spacing: 8) {
                ForEach(0..<controlState.centerItems.count, id: \.self) { index in
                    let item = controlState.centerItems[index]
                    viewForInteraction(item)
                }
            }
            .frame(maxWidth: .infinity)
            
            HStack(spacing: 8) {
                ForEach(0..<controlState.rightOptions.count, id: \.self) { index in
                    let option = controlState.rightOptions[index]
                    viewForOption(option)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .frame(minHeight: 40)
        .padding()
    }
    
    @ViewBuilder
    private func viewForOption(_ option: VideoEditorControlItem.Option) -> some View {
        let image: SafeSFSymbol = switch option {
        case .trimCut:
            .squareshape.split_2x2Dotted
        case .separate:
            .chart.barXaxis
        case .eraseBackground:
            .eraser.lineDashedFill
        case .cancelEditing:
            .xmark
        case .acceptEditing:
            .checkmark
        }
        Button(action: {
            withAnimation {
                controlState.optionChoosed(option)
            }
        }, label: {
            Image(image)
        })
    }
    
    @ViewBuilder
    private func viewForInteraction(_ interaction: VideoEditorControlItem.Interaction) -> some View {
        switch interaction {
        case .playPause:
            Button(action: {
                controlState.itemInteracted(interaction)
            }, label: {
                Image(state.isVideoPlaying ? .pause.fill : .play.fill)
            })
        case .enableDisable:
            Toggle("", isOn: $state.isEraseEnabled)
                .labelsHidden()
                .tint(Color.accentColor)
        }
    }
}
