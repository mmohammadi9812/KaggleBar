// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "KaggleBar",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(name: "KaggleBarCore", targets: ["KaggleBarCore"]),
        .executable(name: "KaggleBar", targets: ["KaggleBar"]),
        .executable(name: "KaggleBarCLI", targets: ["KaggleBarCLI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.6.0"),
    ],
    targets: [
        .target(
            name: "KaggleBarCore",
            path: "Sources/KaggleBarCore"
        ),
        .executableTarget(
            name: "KaggleBar",
            dependencies: [
                .target(name: "KaggleBarCore")
            ],
            path: "Sources/KaggleBar",
            resources: [.process("Resources")]
        ),
        .executableTarget(
            name: "KaggleBarCLI",
            dependencies: [
                .target(name: "KaggleBarCore"),
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ],
            path: "Sources/KaggleBarCLI"
        ),
        .testTarget(
            name: "KaggleBarCoreTests",
            dependencies: [
                .target(name: "KaggleBarCore")
            ],
            path: "Tests/KaggleBarCoreTests"
        ),
    ]
)
