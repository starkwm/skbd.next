// swift-tools-version: 6.2

import PackageDescription

let package = Package(
  name: "skbd",
  platforms: [
    .macOS(.v26)
  ],
  products: [
    .executable(name: "skbd", targets: ["Skbd"])
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0")
  ],
  targets: [
    .executableTarget(
      name: "Skbd",
      dependencies: [
        "SkbdCore",
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
      ],
    ),
    .target(
      name: "SkbdCore"
    ),
    .testTarget(
      name: "SkbdCoreTests",
      dependencies: ["SkbdCore"],
    ),
  ]
)
