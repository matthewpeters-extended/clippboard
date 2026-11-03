// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "Clippboard",
    platforms: [.macOS("26.0")],
    dependencies: [
        .package(url: "https://github.com/sparkle-project/Sparkle", from: "2.6.4"),
    ],
    targets: [
        .target(name: "ClippboardCore"),
        .executableTarget(name: "Clippboard", dependencies: ["ClippboardCore", .product(name: "Sparkle", package: "Sparkle")]),
        .testTarget(name: "ClippboardCoreTests", dependencies: ["ClippboardCore"]),
    ]
)
