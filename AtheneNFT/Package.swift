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
        .package(url: "https://github.com/web3swift-team/web3swift.git", from: "3.0.0"),
        .package(url: "https://github.com/attaswift/BigInt.git", from: "5.3.0"),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", from: "1.7.0")
    ],
    targets: [
        .executableTarget(
            name: "AtheneNFT",
            dependencies: [
                .product(name: "web3swift", package: "web3swift"),
                .product(name: "BigInt", package: "BigInt"),
                .product(name: "CryptoSwift", package: "CryptoSwift")
            ],
            path: "Sources/AtheneNFT"),
        .testTarget(
            name: "AtheneNFTTests",
            dependencies: ["AtheneNFT"])
    ]
)
