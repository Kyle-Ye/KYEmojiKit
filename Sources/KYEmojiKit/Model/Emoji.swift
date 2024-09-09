//
//  Emoji.swift
//
//
//  Created by Kyle on 2024/7/11.
//

import Foundation
import UIKit
import YYText
import KYFoundation

public struct Emoji {
    public let key: String
    public let value: URL
    public let type: EmojiType
    public let startTime: Date?
    public let endTime: Date?
    
    public init(key: String, value: URL, type: EmojiType = .default, startTime: Date? = nil, endTime: Date? = nil) {
        self.key = key
        self.value = value
        self.type = type
        self.startTime = startTime
        self.endTime = endTime
    }
    
    public func shouldDisableEntry(for date: Date = Date()) -> Bool {
        (type == .limited || type == .activity) && hasExpired(for: date)
    }
    
    public func hasExpired(for date: Date = Date()) -> Bool {
        if let startTime, date < startTime {
            return true
        } else if let endTime, date > endTime {
            return true
        } else {
            return false
        }        
    }
}

extension Emoji: Equatable {
    public static func == (lhs: Emoji, rhs: Emoji) -> Bool {
        lhs.key == rhs.key
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(key)
    }
}

extension Emoji: CustomStringConvertible {
    public var description: String {
        "[\(key)]"
    }
}

extension Emoji: Identifiable {
    public var id: String { key }
}

extension Emoji {
    public var image: UIImage? {
        UIImage(contentsOfFile: value.path)
    }
    
    private var horizontalPadding: Double { 1.0 }
    
    public func attachment(for font: UIFont) -> NSTextAttachment {
        guard let image else {
            return NSTextAttachment()
        }        
        let emojiSize = font.lineHeight
        let attachment = NSTextAttachment()
        attachment.image = image
        if #available(iOS 15.0, *) {
            let padding = horizontalPadding
            attachment.bounds = CGRect(x: 0, y: font.descender, width: emojiSize + horizontalPadding * 2, height: emojiSize)
            attachment.lineLayoutPadding = padding
        } else {
            attachment.bounds = CGRect(x: 0, y: font.descender, width: emojiSize, height: emojiSize)
        }
        return attachment
    }
    
    public func yy_attachment(for font: UIFont) -> YYTextAttachment {
        guard let image else {
            return YYTextAttachment()
        }
        let attachment = YYTextAttachment()
        attachment.content = image
        attachment.contentMode = .scaleToFill
        
        let padding = horizontalPadding
        attachment.contentInsets = UIEdgeInsets(top: 0, left: padding, bottom: 0, right: padding)
        return attachment
    }
    
    public func yy_runDelegate(for font: UIFont) -> YYTextRunDelegate {
        let delegate = YYTextRunDelegate()
        delegate.ascent = font.lineHeight + font.descender
        delegate.descent = -font.descender
        delegate.width = font.lineHeight + horizontalPadding * 2
        return delegate
    }
    
    public func attributedString(for font: UIFont) -> NSAttributedString {
        let attachment = attachment(for: font)
        let attributedString = NSMutableAttributedString(attributedString: NSAttributedString(attachment: attachment))
        attributedString.ky.setTextBackedString(
            textBackedString: TextBackedString(string: description),
            range: attributedString.ky.rangeOfAll
        )
        return attributedString
    }
    
    public func yy_attributedString(for font: UIFont) -> NSAttributedString {
        let attachment = yy_attachment(for: font)
        let attributedString = NSMutableAttributedString(attributedString: NSAttributedString(string: YYTextAttachmentToken))
        let range = attributedString.ky.rangeOfAll
        attributedString.yy_setTextAttachment(attachment, range: range)
        attributedString.yy_setRunDelegate(yy_runDelegate(for: font).ctRunDelegate(), range: range)
        attributedString.ky.setTextBackedString(
            textBackedString: TextBackedString(string: description),
            range: range
        )
        return attributedString
    }
}
