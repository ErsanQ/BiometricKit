// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "BiometricKit",
    platforms: [
        .iOS(.v14),
        .macOS(.v11)
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
            path: "Sources/BiometricKit"),
        .testTarget(
            name: "BiometricKitTests",
            dependencies: ["BiometricKit"],
            path: "Tests/BiometricKitTests"),
    ]
)
