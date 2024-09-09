//
//  EmojiManager.swift
//
//
//  Created by Kyle on 2024/7/11.
//

import Foundation
import UIKit
import SwiftUI

public protocol EmojiPanelDelegate: UITextViewDelegate {
    func didClickSendButton()
    func didClickDeleteButton()
    func didSelectEmoji(_ emoji: Emoji)
}

extension EmojiPanelDelegate {
    public func didClickSendButton() {}
    public func didClickDeleteButton() {}
    public func didSelectEmoji(_ emoji: Emoji) {}
}

final class EmojiManager: ObservableObject {
    init(_ optionalBundle: EmojiBundle? = nil) {
        let bundle = optionalBundle ?? EmojiDataManager.shared.bundle
        self.bundle = bundle
        self.emojis = bundle.emojis
    }
        
    private let bundle: EmojiBundle
    
    private let emojis: [Emoji]
    
    var allEmojis: [Emoji] {
        let date = Date()
        return emojis.filter { !$0.shouldDisableEntry(for: date) }
    }
    
    weak var delegate: EmojiPanelDelegate? {
        didSet {
            deleteManager.delegate = delegate
        }
    }
    
    var recentUsedEmojis: [Emoji] {
        let date = Date()
        return recentUsedEmojisKeys
            .compactMap { try? bundle.emoji(for: $0) }
            .filter { !$0.shouldDisableEntry(for: date) }
    }
    
    var suggestedEmojis: [Emoji] {
        var result: [Emoji] = recentUsedEmojis
        let diff = EmojiManager.countLimit - result.count
        
        if diff > 0 {
            let newEmojis = Array(allEmojis.lazy.filter{ !result.contains($0) }.prefix(diff))
            result.append(contentsOf: newEmojis)
        }
        return result
    }
    
    func emoji(for key: String) -> Emoji? {
        emojis.first { $0.key == key }        
    }
    
    private func addRecentUsedEmoji(key: String) {
        var result = recentUsedEmojisKeys
        result.removeAll { $0 == key }
        result.insert(key, at: 0)
        recentUsedEmojisKeys = Array(result.prefix(EmojiManager.countLimit))
    }
    
    private static var countLimit: Int { 7 }
    
    private static var recentUsedEmojisStorageKey: String { "emojis.recent_used" }

    @AppStorage(EmojiManager.recentUsedEmojisStorageKey)
    private var recentUsedEmojisKeys: [String] = []
    
    // MARK: Input related
    
    func selectEmoji(_ emoji: Emoji) {
        UIDevice.current.playInputClick()
        delegate?.didSelectEmoji(emoji)
        addRecentUsedEmoji(key: emoji.key)
    }
    
    final class DeleteManager: ObservableObject {
        @Published var disableDeleteButton = false
        
        fileprivate weak var delegate: EmojiPanelDelegate?
        
        func deleteBackward() {
            delegate?.didClickDeleteButton()
        }
    }
    
    let deleteManager = DeleteManager()
    
    var disableDeleteButton: Bool {
        get { deleteManager.disableDeleteButton }
        set { deleteManager.disableDeleteButton = newValue }
    }
    
    final class TipManager: ObservableObject {
        @Published var pressLocation: CGPoint = .zero
    }
    
    let tipManager = TipManager()
    
    var pressLocation: CGPoint {
        get { tipManager.pressLocation }
        set { tipManager.pressLocation = newValue }
    }
    
    func resetPressLocation() {
        pressLocation = .zero
    }
}

extension [String]: RawRepresentable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode([String].self, from: data)
        else {
            return nil
        }
        self = result
    }

    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else { return "[]" }
        return result
    }
}
