// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CodeView",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
//        .macCatalyst(.v17),
//        .tvOS(.v13),
//        .watchOS(.v6),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "CodeView",
            targets: ["CodeView"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "CodeView"),
        .testTarget(
            name: "CodeViewTests",
            dependencies: ["CodeView"]
        ),
    ]
)
