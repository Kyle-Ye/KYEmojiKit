//
//  EmojiType.swift
//
//
//  Created by Kyle on 2024/7/24.
//

import Foundation

public enum EmojiType: Int, Codable, CustomStringConvertible, CaseIterable, Identifiable {
    case `default` = 0
    case new = 1
    case activity = 2
    case limited = 3
    
    public var id: Int { rawValue }
    
    public var description: String {
        switch self {
            case .default: "default"
            case .new: "new"
            case .activity: "activity"
            case .limited: "limited"
        }
    }
    
    // We need the explit decoder method to provide default value
    // otherwize the old client will fail to decode the new enum value
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(Int.self)
        self = EmojiType(rawValue: value) ?? .default
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}
