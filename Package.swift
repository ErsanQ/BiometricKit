// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "BiometricKit",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .tvOS(.v14),
        .watchOS(.v7),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "BiometricKit",
            targets: ["BiometricKit"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "BiometricKit",
            dependencies: [],
            path: "Sources/BiometricKit",
            exclude: ["Examples"]),
    ]
)
