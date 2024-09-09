//
//  EmojiView.swift
//
//
//  Created by Kyle on 2024/7/11.
//

import SwiftUI
import SDWebImageSwiftUI

struct EmojiView: View {
    var emoji: Emoji
    
    @Environment(\.emojiViewLabelHidden) private var labelHidden
    
    @State private var isShowingPopover = false
    
    var body: some View {
        WebImage(url: emoji.value) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(4)
                .overlay(
                    Group {
                        if !labelHidden {
                            label
                        }
                    },
                    alignment: .topTrailing
                )
        } placeholder: {
            Color.gray
                .aspectRatio(1, contentMode: .fill)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
    
    private var label: some View {
        EmojiTypeLabel(type: type)
            .offset(x: 4, y: -4)
    }
    
    private var type: EmojiType {
        if emoji.type == .new && emoji.hasExpired() {
            return .default
        } else {
            return emoji.type
        }
    }
}

private struct EmojiViewLabelHiddenKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var emojiViewLabelHidden: Bool {
        get { self[EmojiViewLabelHiddenKey.self] }
        set { self[EmojiViewLabelHiddenKey.self] = newValue }
    }
}

extension View {
    func emojiViewLabelHidden(_ hidden: Bool) -> some View {
        environment(\.emojiViewLabelHidden, hidden)
    }
}

#if DEBUG

#Preview {
    VStack {
        ForEach(EmojiType.allCases) { type in
            HStack {
                EmojiView(emoji: .init(
                    key: "A",
                    value: URL(string: "https://picsum.photos/200")!,
                    type: type
                ))
                .emojiViewLabelHidden(.random())
                .frame(width: 40, height: 40)
                EmojiView(emoji: .init(
                    key: "A",
                    value: URL(string: "https://example.com")!,
                    type: type
                ))
                .emojiViewLabelHidden(.random())
                .frame(width: 40, height: 40)
            }
        }
    }
    .background(Color.gray)
    .scaleEffect(4)
}

#endif
