//
//  PanelDeleteButton.swift
//
//
//  Created by Kyle on 2024/8/7.
//

import SwiftUI

struct PanelDeleteButton: View {
    @EnvironmentObject private var manager: EmojiManager.DeleteManager
    
    var body: some View {
        #if DEBUG
        if #available(iOS 15.0, *) {
            let _ = Self._printChanges()
        }
        #endif
        Button {
            manager.deleteBackward()
        } label: {
            Image(systemName: "delete.left")
                .padding(.horizontal, 22)
                .padding(.vertical, 6)
                .background(Capsule().fill(Color.white.opacity(0.15)))
                .overlay(Capsule().stroke(Color.white.opacity(0.1), lineWidth: 0.5))
        }
        .buttonStyle(CloseButtonStyle())
        .disabled(manager.disableDeleteButton)
    }
    
    private struct CloseButtonStyle: ButtonStyle {
        @Environment(\.isEnabled) private var isEnabled

        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .foregroundColor(isEnabled ? .white.opacity(0.75) : .white.opacity(0.15))
        }
    }
}

#if DEBUG

#Preview {
    VStack {
        PanelDeleteButton()
        PanelDeleteButton()
            .disabled(true)
    }
    .padding()
    .background(Color.black)
    .environmentObject(EmojiManager.DeleteManager())
    .scaleEffect(5)
}

#endif
