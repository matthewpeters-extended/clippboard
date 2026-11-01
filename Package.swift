// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "Paste",
    platforms: [.macOS("26.0")],
    dependencies: [
        .package(url: "https://github.com/sparkle-project/Sparkle", from: "2.6.4"),
    ],
    targets: [
        .target(name: "PasteCore"),
        .executableTarget(name: "Paste", dependencies: ["PasteCore", .product(name: "Sparkle", package: "Sparkle")]),
        .testTarget(name: "PasteCoreTests", dependencies: ["PasteCore"]),
    ]
)
