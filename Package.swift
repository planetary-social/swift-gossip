// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "swift-gossip",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
    ],
    products: [
        .library(
            name: "Gossip",
            targets: ["Gossip"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio",
                 .upToNextMajor(from: "2.0.0")),
        .package(url: "https://github.com/apple/swift-log",
                 .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/apple/swift-metrics",
                 .upToNextMajor(from: "2.0.0")),
    ],
    targets: [
        .target(
            name: "Gossip",
            dependencies: [
                .product(name: "NIO",
                         package: "swift-nio"),
                .product(name: "Logging",
                         package: "swift-log"),
                .product(name: "Metrics",
                         package: "swift-metrics"),
            ]),
        .testTarget(
            name: "GossipTests",
            dependencies: [
                "Gossip",
            ]),
    ]
)
