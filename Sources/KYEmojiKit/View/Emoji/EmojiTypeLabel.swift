//
//  EmojiTypeLabel.swift
//
//
//  Created by Kyle on 2024/7/24.
//

import SwiftUI
import KYFoundation
import KYUIKit
import KYSwiftUI

struct EmojiTypeLabel: View {
    let type: EmojiType
    
    var body: some View {
        switch type {
        case .default:
            EmptyView()
        case .new:
            TagLabel(text: "New".ky.localized, textColor: .white) {
                Color.orange
            }
        case .activity:
            TagLabel(text: "Activity".ky.localized, textColor: .white) {
                LinearGradient(
                    colors: [
                        .init(.ky.hex("#00F0FF")),
                        .init(.ky.hex("#8200D2")),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        case .limited:
            TagLabel(text: "Limited".ky.localized, textColor: .black) {
                Color.orange
            }
        }
    }
}

private struct TagLabel<Background: View>: View {
    let text: String
    let textColor: Color
    // FIXME: Refactor me after we drop iOS 14 support (Use ShapeStyle)
    let background: () -> Background
    
    private let shape = UnevenRoundedRectangle(cornerRadii: RectangleCornerRadii(topLeading: 2, bottomLeading: 4, bottomTrailing: 2, topTrailing: 4))
    
    var body: some View {
        Text(text)
            .font(.system(size: 8))
            .foregroundColor(textColor)
            .padding(.horizontal, 2)
            .padding(.vertical, 0.5)
            .background(background())
            .clipShape(shape)
            .overlay(shape.strokeBorder(Color.gray, lineWidth: 0.5))
    }
}

#if DEBUG

#Preview {
    VStack {
        ForEach(EmojiType.allCases) { type in
            EmojiTypeLabel(type: type)
        }
    }
    .scaleEffect(8)
}

#endif
