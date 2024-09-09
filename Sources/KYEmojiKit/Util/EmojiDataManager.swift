//
//  EmojiDataManager.swift
//
//
//  Created by Kyle on 2024/8/6.
//

import UIKit
import Foundation

public enum EmojiReplaceResult: String {
    case none = ""
    case with
    case without
    case only
}

public final class EmojiDataManager {
    public static let shared = EmojiDataManager()
    
    public var bundle = EmojiBundle.load() ?? .invalid
    
    /// Update the attributedString to replace emoji description with emoji attachment image
    /// - Parameters:
    ///   - attributedString: The attributedString you'd like to update
    ///   - font: The font to determine the emoji's zie
    /// - Returns: A result indicating if attributedString have any emoji replaced.
    @discardableResult
    public func replaceEmoji(for attributedString: NSMutableAttributedString, font: UIFont) -> EmojiReplaceResult {
        guard attributedString.length != 0 else {
            return .without
        }
        let plainText = attributedString.ky.plainText
        let matchedResults = matchingEmojis(for: plainText)
        guard !matchedResults.isEmpty else {
            return .without
        }
        var offset = 0
        var totalLength = 0
        for result in matchedResults {
            let emojiAttributedString = result.emoji.attributedString(for: font)
            let description = result.emoji.description as NSString
            let actualRange = NSMakeRange(result.range.location - offset, description.length)
            attributedString.replaceCharacters(in: actualRange, with: emojiAttributedString)
            offset += (description.length - emojiAttributedString.length)
            totalLength += result.range.length
        }
        return (plainText as NSString).length == totalLength ? .only : .with
    }
    
    /// Update the attributedString to replace emoji description with emoji attachment image
    /// - Parameters:
    ///   - attributedString: The attributedString you'd like to update
    ///   - font: The font to determine the emoji's zie
    /// - Returns: A result indicating if attributedString have any emoji replaced.
    @discardableResult
    public func yy_replaceEmoji(for attributedString: NSMutableAttributedString, font: UIFont) -> EmojiReplaceResult {
        guard attributedString.length != 0 else {
            return .without
        }
        let plainText = attributedString.ky.plainText
        let matchedResults = matchingEmojis(for: plainText)
        guard !matchedResults.isEmpty else {
            return .without
        }
        var offset = 0
        var totalLength = 0
        for result in matchedResults {
            let emojiAttributedString = result.emoji.yy_attributedString(for: font)
            let description = result.emoji.description as NSString
            let actualRange = NSMakeRange(result.range.location - offset, description.length)
            attributedString.replaceCharacters(in: actualRange, with: emojiAttributedString)
            offset += (description.length - emojiAttributedString.length)
            totalLength += result.range.length
        }
        return (plainText as NSString).length == totalLength ? .only : .with
    }
    
    public func replaceEmoji(for text: String) -> EmojiReplaceResult {
        guard !text.isEmpty else {
            return .without
        }
        let plainText = text
        let matchedResults = matchingEmojis(for: plainText)
        guard !matchedResults.isEmpty else {
            return .without
        }
        var totalLength = 0
        for result in matchedResults {
            guard result.range.location == totalLength else {
                return .with
            }
            totalLength += result.range.length
        }        
        return (plainText as NSString).length == totalLength ? .only : .with
    }
    
    private struct EmojiMatchingResult {
        let range: NSRange
        let emoji: Emoji
    }
    
    private func matchingEmojis(for text: String) -> [EmojiMatchingResult] {
        guard !text.isEmpty else {
            return []
        }
        guard let regex = try? NSRegularExpression(pattern: "\\[.+?\\]", options: []) else {
            return []
        }
        let results = regex.matches(in: text, options: [], range: NSRange(location: 0, length: (text as NSString).length))
        return results.compactMap { result in
            let range = result.range
            let emojiString = (text as NSString).substring(with: NSMakeRange(range.location + 1, range.length - 2))
            guard let configEmoji = bundle.config.emojis.first(where: { $0.key == emojiString }) else {
                return nil
            }
            return EmojiMatchingResult(range: result.range, emoji: bundle.emoji(for: configEmoji))
        }
    }
}
