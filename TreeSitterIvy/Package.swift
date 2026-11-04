// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TreeSitterIvy",
    platforms: [
        .macOS("13"),
        .iOS("16"),
    ],
    products: [
        .library(name: "TreeSitterIvy", targets: ["TreeSitterIvy"]),
    ],
    dependencies: [
        .package(url: "https://github.com/tree-sitter/swift-tree-sitter", from: "0.25.0"),
    ],
    targets: [
        .target(
            name: "CTreeSitterIvy",
            path: "src",
            sources: ["parser.c"],
            publicHeadersPath: "include",
            cSettings: [.headerSearchPath(".")]
        ),
        .target(
            name: "TreeSitterIvy",
            dependencies: [
                "CTreeSitterIvy",
                .product(name: "SwiftTreeSitter", package: "swift-tree-sitter"),
            ],
            resources: [.copy("queries")]
        ),
    ]
)
