//
//  EmojiSuggestionBar.swift
//
//
//  Created by Kyle on 2024/8/1.
//

import SwiftUI
import UIKit

struct EmojiSuggestionBar: View {
    // NOTE: On purpose not using @EnvironmentObject. We do not want dynamic behavior.
    let manager: EmojiManager
    
    var body: some View {
        #if DEBUG
        if #available(iOS 15.0, *) {
            let _ = Self._printChanges()
        }
        #endif
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(manager.suggestedEmojis) { emoji in
                    EmojiView(emoji: emoji)
                        .emojiViewLabelHidden(true)
                        .frame(width: 40, height: 40)
                        .onTapGesture {
                            manager.selectEmoji(emoji)
                        }
                }
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 16)
        }
        .background(Color.bg2)
        .shadow(color: .white.opacity(0.04), radius: 0, y: -0.5)
    }
}

#Preview {
    EmojiSuggestionBar(manager: EmojiManager())
}
