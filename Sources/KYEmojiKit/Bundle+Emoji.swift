//
//  Bundle+KY.swift
//
//
//  Created by Kyle on 2024/4/20.
//

import Foundation

extension Bundle {
    /// The emoji bundle
    public static var emoji: Bundle {
        Bundle.package
    }
}

private class BundleFinder {}

extension Foundation.Bundle {
    fileprivate static var package: Bundle = {
        let bundleName = "KYEmojiKit_KYEmojiKit"
        let candidates = [
            Bundle.main.resourceURL,
            Bundle(for: BundleFinder.self).resourceURL,
            Bundle.main.bundleURL,
            Bundle(for: BundleFinder.self).resourceURL?.deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent(),
            Bundle(for: BundleFinder.self).resourceURL?.deletingLastPathComponent().deletingLastPathComponent(),
        ]

        for candidate in candidates {
            let bundlePath = candidate?.appendingPathComponent(bundleName + ".bundle")
            if let bundle = bundlePath.flatMap(Bundle.init(url:)) {
                return bundle
            }
        }
        fatalError("unable to find bundle")
    }()
}
