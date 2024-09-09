//
//  EmojiBundleError.swift
//
//
//  Created by Kyle on 2024/7/11.
//

import Foundation

enum EmojiBundleError: Error {
    case bunldeInvalid
    case emojiNotFound(key: String)
    case emojiFileNotExist(url: URL)
}
