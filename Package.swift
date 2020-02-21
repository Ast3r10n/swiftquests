// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "Requests",
    products: [
        .library(
            name: "Requests",
            targets: ["Requests"]),
    ],
    targets: [
        .target(
            name: "Requests",
            dependencies: []),
        .testTarget(
            name: "RequestsTests",
            dependencies: ["Requests"]),
    ]
)
