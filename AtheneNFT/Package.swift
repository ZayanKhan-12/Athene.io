// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "AtheneNFT",
    platforms: [
        .iOS(.v14),
        .macOS(.v10_15)
    ],
    products: [
        .executable(
            name: "AtheneNFT",
            targets: ["AtheneNFT"]),
    ],
    dependencies: [
        .package(url: "https://github.com/web3swift-team/web3swift.git", .upToNextMajor(from: "3.1.2")),
        .package(url: "https://github.com/attaswift/BigInt.git", .upToNextMajor(from: "5.3.0")),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", .upToNextMajor(from: "1.7.0"))
    ],
    targets: [
        .executableTarget(
            name: "AtheneNFT",
            dependencies: [
                .product(name: "web3swift", package: "web3swift"),
                .product(name: "BigInt", package: "BigInt"),
                .product(name: "CryptoSwift", package: "CryptoSwift")
            ],
            path: "Sources/AtheneNFT",
            resources: [
                .process("Resources")
            ])
        // Removed testTarget since it's not properly set up yet
    ]
)
