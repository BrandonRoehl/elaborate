// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

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


make(Context.packageDirectory, "lib/Elb.xcframework")

let package = Package(
    name: "Elb",
    platforms: [
        .macOS("13"),
        .iOS("16"),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Elb",
            targets: ["Elb", "ElbLib"])
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Elb",
            dependencies: ["ElbLib"]
        ),
        .binaryTarget(
            name: "ElbLib",
            path: "./lib/Elb.xcframework"
        ),
        .testTarget(
            name: "ElbTests",
            dependencies: ["Elb", "ElbLib"],
        ),
    ]
)
