//
//  EmojiGrid.swift
//
//
//  Created by Kyle on 2024/8/7.
//

import SwiftUI

struct EmojiGrid: View {
    let manager: EmojiManager
    let emojis: [Emoji]
    
    init(manager: EmojiManager, emojis: [Emoji]) {
        self.manager = manager
        self.emojis = emojis
    }

    private let columns = [
        GridItem(.adaptive(minimum: 39, maximum: 56), spacing: 12),
    ]
    
    var body: some View {
        #if DEBUG
        if #available(iOS 15.0, *) {
            let _ = Self._printChanges()
        }
        #endif
        LazyVGrid(
            columns: columns,
            alignment: .leading,
            spacing: 12
        ) {
            ForEach(emojis) { emoji in
                EmojiView(emoji: emoji)
                    .onTapGesture {
                        manager.selectEmoji(emoji)
                    }
                    .background(
                        GeometryReader { proxy in
                            Color.clear.preference(
                                key: ModelFrameKey.self,
                                value: [
                                    ModelFrame(
                                        id: emoji.id,
                                        frame: proxy.frame(in: .named("EmojiPanel"))
                                    ),
                                ]
                            )
                        }
                    )
            }
        }
    }
}

#if DEBUG
#Preview {
    let manager = EmojiManager()
    return EmojiGrid(manager: manager, emojis: manager.allEmojis)
}

#endif
