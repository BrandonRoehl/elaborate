// swift-tools-version: 6.1
import PackageDescription
import Foundation

/// Runs `make` in the package directory so that `swift build` produces any generated artifacts.
func make(_ directory: String, _ target: String? = nil) {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
    process.currentDirectoryURL = URL(fileURLWithPath: directory)
    var environment = ProcessInfo.processInfo.environment
    let extra = ["/opt/homebrew/bin", "/usr/local/bin", "/usr/local/go/bin"]
    environment["PATH"] = (extra + [environment["PATH"] ?? "/usr/bin:/bin"]).joined(separator: ":")
    process.environment = environment
    process.arguments = ["make", "--no-print-directory"] + (target.map { [$0] } ?? [])
    process.standardOutput = FileHandle.standardError
    do {
        try process.run()
        process.waitUntilExit()
        if process.terminationStatus != 0 {
            fatalError("make failed in \(directory) with status \(process.terminationStatus)")
        }
    } catch {
        fatalError("unable to run make in \(directory): \(error)")
    }
}


make(Context.packageDirectory, "src/parser.c")

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
