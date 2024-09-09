//
//  CommentKeyboardType.swift
//
//
//  Created by Kyle on 2024/8/1.
//

import SwiftUI

public enum EmojiKeyboardType {
    case normal
    case keyboard
    case emoji
}

extension EmojiKeyboardType {
    public var image: UIImage {
        switch self {
        case .normal, .keyboard: UIImage(systemName: "face.smiling")!
        case .emoji: UIImage(systemName: "keyboard")!
        }
    }
    
    public mutating func toggle() {
        switch self {
            case .normal, .keyboard:
                self = .emoji
            case .emoji:
                self = .keyboard
        }
    }
}

extension EmojiKeyboardType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .normal: "normal"
        case .keyboard: "keyboard"
        case .emoji: "emoji"
        }
    }
}
