//
//  EmojiPanelGestureOverlay.swift
//
//
//  Created by Kyle on 2024/8/15.
//

import SwiftUI

struct EmojiGridGestureOverlay: View {
    
    let manager: EmojiManager
    
    @State private var tipEmojiKey: String?
    @State private var tipEmojiPosition: CGPoint = .zero
    
    @EnvironmentObject private var tipManager: EmojiManager.TipManager
    @Environment(\.modelFrames) private var modelFrames
    
    var body: some View {
        tipView
            .onChange(of: tipManager.pressLocation) { newValue in
                let modelFrame = frame(containing: newValue)
                if let modelFrame {
                    tipEmojiKey = modelFrame.id
                    let frame = modelFrame.frame
                    let position = CGPoint(x: frame.midX, y: frame.midY - (94 + frame.height) / 2)
                    if position != tipEmojiPosition {
                        feedback()
                    }
                    tipEmojiPosition = position
                } else {
                    tipEmojiKey = nil
                    tipEmojiPosition = .zero
                }

            }
    }
    
    @ViewBuilder
    private var tipView: some View {
        if let tipEmojiKey, let emoji = manager.emoji(for: tipEmojiKey) {
            EmojiTipView(emoji: emoji)
                .frame(width: 72, height: 94)
                .position(tipEmojiPosition)
        }
    }
    
    private func frame(containing point: CGPoint) -> ModelFrame? {
        guard let frame = modelFrames.first(where: { $0.frame.contains(point) }) else {
            return nil
        }
        return frame
    }
    
    private func feedback() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}
