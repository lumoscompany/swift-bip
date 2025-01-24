// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-bip",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .watchOS(.v6),
        .tvOS(.v13),
    ],
    products: [
        .library(name: "BIP", targets: ["BIP"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/attaswift/BigInt.git",
            .upToNextMajor(from: "5.4.1")
        ),
        .package(
            url: "https://github.com/apple/swift-crypto.git",
            .upToNextMajor(from: "3.8.0")
        ),
        .package(
            url: "https://github.com/unistash-io/libkeccak.swift.git",
            .upToNextMajor(from: "0.0.1")
        ),
        .package(
            url: "https://github.com/unistash-io/libsecp256k1.swift.git",
            .upToNextMajor(from: "0.0.1")
        ),
        .package(
            url: "https://github.com/unistash-io/swift-essentials.git",
            .upToNextMajor(from: "0.0.4")
        ),
    ],
    targets: [
        .target(
            name: "BIP",
            dependencies: [
                "ObscureKit",
                .product(name: "BigInt", package: "BigInt"),
                .product(name: "Crypto", package: "swift-crypto"),
                .product(name: "Essentials", package: "swift-essentials"),
            ],
            path: "Sources/BIP"
        ),
        .target(
            name: "ObscureKit",
            dependencies: [
                .product(name: "BigInt", package: "BigInt"),
                .product(name: "Crypto", package: "swift-crypto"),
                .product(name: "libsecp256k1", package: "libsecp256k1.swift"),
                .product(name: "libkeccak", package: "libkeccak.swift"),
                .product(name: "Essentials", package: "swift-essentials"),
            ],
            path: "Sources/ObscureKit"
        ),
        .testTarget(
            name: "BIPTests",
            dependencies: ["BIP", "ObscureKit"]
        ),
    ]
)
