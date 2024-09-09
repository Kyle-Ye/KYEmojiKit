// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "KYEmojiKit",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "KYEmojiKit",
            targets: ["KYEmojiKit"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/SDWebImage/SDWebImageSwiftUI.git", from: "3.1.2"),
        .package(url: "https://github.com/marmelroy/Zip.git", from: "2.1.2"),
        .package(url: "https://github.com/Kyle-Ye/YYText.git", from: "1.0.0"),
        .package(url: "https://github.com/Kyle-Ye/KYFoundation.git", from: "0.0.2"),
        .package(url: "https://github.com/Kyle-Ye/KYUIKit.git", from: "0.0.2"),
        .package(url: "https://github.com/Kyle-Ye/KYSwiftUI.git", from: "0.0.1"),
    ],
    targets: [
        .target(
            name: "KYEmojiKit",
            dependencies: [
                .product(name: "SDWebImageSwiftUI", package: "SDWebImageSwiftUI"),
                .product(name: "Zip", package: "Zip"),
                .product(name: "YYText", package: "YYText"),
                .product(name: "KYFoundation", package: "KYFoundation"),
                .product(name: "KYUIKit", package: "KYUIKit"),
                .product(name: "KYSwiftUI", package: "KYSwiftUI"),
            ],
            resources: [.copy("emojis_bundle")]
        ),
    ]
)
