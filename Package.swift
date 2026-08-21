// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "KaggleBar",
    platforms: [
        .macOS(.v13)
    ],
    targets: [
        .executableTarget(
            name: "KaggleBar",
            path: "Sources"
        )
    ]
)
