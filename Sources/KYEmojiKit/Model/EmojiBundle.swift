//
//  EmojiBundle.swift
//
//
//  Created by Kyle on 2024/7/11.
//

import Foundation
import Zip
import os.log
import UIKit

public class EmojiBundle {
    static let invalid = EmojiBundle()
    
    @_spi(Debug)
    public static func load(zipURL: URL) -> EmojiBundle? {
        do {
            let bundleURL = try Zip.quickUnzipFile(zipURL)
            return try EmojiBundle(bundleURL: bundleURL)
        } catch {
            Self.logger.error("Failed to load emojis bundle: \(error.localizedDescription)")
        }
        return nil
    }
    
    public static func load(url: URL? = nil) -> EmojiBundle? {
        if let url {
            do {
                return try EmojiBundle(bundleURL: url)
            } catch {
                Self.logger.error("Failed to load emojis bundle: \(error.localizedDescription)")
            }
            return nil
        } else {
            do {
                // Local bundle fallback
                let emojisURL = Bundle.emoji.bundleURL.appendingPathComponent("emojis_bundle")
                return try EmojiBundle(bundleURL: emojisURL)
            } catch {
                Self.logger.error("Failed to load local emojis bundle: \(error.localizedDescription)")
            }
            return nil
        }
    }
    
    struct Config: Codable {
        var emojis: [ConfigEmoji]
        var version: Int
        
        struct ConfigEmoji: Codable {
            let key: String
            let path: String
            let type: EmojiType
            let startTime: Date?
            let endTime: Date?
            
            init(from decoder: any Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                self.key = try container.decode(String.self, forKey: .key)
                self.path = try container.decode(String.self, forKey: .path)
                self.type = try container.decodeIfPresent(EmojiType.self, forKey: .type) ?? .default
                self.startTime = try container.decodeIfPresent(Date.self, forKey: .startTime)
                self.endTime = try container.decodeIfPresent(Date.self, forKey: .endTime)
            }
            
            func hasExpired(for date: Date = Date()) -> Bool {
                if let startTime, date < startTime {
                    return true
                } else if let endTime, date > endTime {
                    return true
                } else {
                    return false
                }
            }
        }
    }
    
    let bundleURL: URL
    let config: Config
    
    private init(bundleURL: URL) throws {
        let configURL = bundleURL.appendingPathComponent("config.json")
        if !FileManager.default.fileExists(atPath: configURL.path) {
            throw EmojiBundleError.bunldeInvalid
        }
        self.bundleURL = bundleURL
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        self.config = try decoder.decode(Config.self, from: Data(contentsOf: configURL))
        #if DEBUG
        try bundleEmojisDictionayCheck()
        #endif
    }
    
    private init() {
        self.bundleURL = URL(fileURLWithPath: "")
        self.config = Config(emojis: [], version: 0)
    }
    
    func emoji(for key: String) throws -> Emoji {
        guard let configEmoji = config.emojis.first(where: { $0.key == key }) else {
            Self.logger.error("No emoji found for key: \(key)")
            throw EmojiBundleError.emojiNotFound(key: key)
        }
        return emoji(for: configEmoji)
    }
    
    func emoji(for configEmoji: Config.ConfigEmoji) -> Emoji {
        let emojiURL = bundleURL.appendingPathComponent(configEmoji.path)
        #if DEBUG
        if !FileManager.default.fileExists(atPath: emojiURL.path) {
            Self.logger.error("Emoji file does not exist: \(emojiURL.path)")
        }
        #endif
        return Emoji(
            key: configEmoji.key,
            value: emojiURL,
            type: configEmoji.type,
            startTime: configEmoji.startTime,
            endTime: configEmoji.endTime
        )
    }
    
    public var emojiKeys: [String] {
        config.emojis.map(\.key)
    }
    
    public var emojis: [Emoji] {
        config.emojis.compactMap { emoji(for: $0) }
    }
    
    // MARK: - Logger
    
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "EmojiBundle")
    
    // MARK: - Check
    
    @inline(__always)
    private var needBundleEmojisDictionayCheck: Bool {
        #if DEBUG
        true
        #else
        false
        #endif
    }
    
    private func bundleEmojisDictionayCheck() throws {
        for emoji in config.emojis {
            let emojiURL = bundleURL.appendingPathComponent(emoji.path)
            guard FileManager.default.fileExists(atPath: emojiURL.path) else {
                throw EmojiBundleError.emojiFileNotExist(url: emojiURL)
            }
        }
    }
}
