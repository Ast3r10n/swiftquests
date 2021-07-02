// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "SwiftQuests",
  products: [
    .library(
      name: "SwiftQuests",
      targets: ["SwiftQuests"]),
  ],
  targets: [
    .target(
      name: "SwiftQuests",
      dependencies: []),
    .testTarget(
      name: "SwiftQuestsTests",
      dependencies: ["SwiftQuests"]),
  ]
)
