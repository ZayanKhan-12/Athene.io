// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "AtheneNFT",
    platforms: [
        .iOS(.v14),
    ],
    products: [
        .executable(
            name: "AtheneNFT",
            targets: ["AtheneNFT"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Boilertalk/Web3.swift.git", from: "0.8.0")
    ],
    targets: [
        .target(
            name: "AtheneNFT",
            dependencies: [
                .product(name: "Web3", package: "Web3.swift"),
            ]),
        .testTarget(
            name: "AtheneNFTTests",
            dependencies: ["AtheneNFT"]),
    ]
)
