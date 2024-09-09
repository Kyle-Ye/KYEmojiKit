//
//  EmojiPanel.swift
//
//
//  Created by Kyle on 2024/7/11.
//

import SwiftUI
import KYUIKit

struct EmojiPanel: View {
    // NOTE: On purpose not using @EnvironmentObject. We do not want dynamic behavior.
    let manager: EmojiManager
    
    @State private var modelFrames: Set<ModelFrame> = []
    
    var body: some View {
        #if DEBUG
        if #available(iOS 15.0, *) {
            let _ = Self._printChanges()
        }
        #endif
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 24) {
                if !manager.recentUsedEmojis.isEmpty {
                    recentEmojisView
                }
                allEmojisView
            }
            .padding(.top, 16)
            .padding(.horizontal, 12)
            .padding(.bottom, 108)
        }
        .onPreferenceChange(ModelFrameKey.self) { frames in
            modelFrames = frames
        }
        .overlay(deleteButton, alignment: .bottomTrailing)
        .background(Color.bg2)
        .ignoresSafeArea()
        .coordinateSpace(name: "EmojiPanel")
        .overlay(
            EmojiGridGestureOverlay(manager: manager)
                .environmentObject(manager.tipManager)
        )
        .environment(\.modelFrames, modelFrames)
    }
    
    private var recentEmojisView: some View {
        VStack(alignment: .leading) {
            Text("Recent".ky.localized)
                .foregroundColor(.gray)
            EmojiGrid(manager: manager, emojis: manager.recentUsedEmojis)
                .emojiViewLabelHidden(true)
        }
    }
        
    private var allEmojisView: some View {
        VStack(alignment: .leading) {
            Text("All".ky.localized)
                .foregroundColor(.gray)
            EmojiGrid(manager: manager, emojis: manager.allEmojis)
                .emojiViewLabelHidden(false)
        }
    }
    
    private var deleteButton: some View {
        PanelDeleteButton()
            .padding([.trailing, .top], 18)
            .padding(.leading, 24)
            .padding(.bottom, 56)
            .background(Color.bg2)
            .shadow(color: .bg2, radius: 12, x: 0, y: -20)
            .environmentObject(manager.deleteManager)
    }
}

#if DEBUG
#Preview {
    VStack {
        Spacer()
        EmojiPanel(manager: EmojiManager())
            .frame(height: 368, alignment: .bottom)
    }
}
#endif

extension Color {
    static var bg2: Color {
        .init(.bg2)
    }
}

extension UIColor {
    static var bg2: UIColor {
        UIColor.ky.hex("#1C1D20")
    }
}
