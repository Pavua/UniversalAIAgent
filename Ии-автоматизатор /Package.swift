// swift-tools-version:5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AIHelper",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
        .watchOS(.v9),
        .macCatalyst(.v17)
    ],
    dependencies: [
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.0.6"),
        .package(url: "https://github.com/alexrozanski/llama.swift.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", from: "4.2.2"),
        .package(url: "https://github.com/apple/swift-syntax.git", branch: "main"),
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "6.0.0"),
        // removed swift-transformers integration for now
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "AIHelperMacOS",
            dependencies: [
                "Yams",
                .product(name: "llama", package: "llama.swift"),
                .product(name: "KeychainAccess", package: "KeychainAccess"),
                .product(name: "GRDB", package: "GRDB.swift"),
                // MLX support stub removed until stable integration
            ],
            path: "Sources",
            exclude: ["ScaffoldMacros"],
            swiftSettings: [
                .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release))
            ]
        ),
        .target(
            name: "AIHelperMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ],
            path: "Macros/AIHelperMacros"
        ),
        .plugin(
            name: "ScaffoldPlugin",
            capability: .command(intent: .custom(verb: "aihelper-scaffold", description: "Generate Swift scaffolding")),
            dependencies: []
        ),
        .testTarget(
            name: "AIHelperMacOSTests",
            dependencies: [
                "AIHelperMacOS"
            ],
            path: "Tests/AIHelperMacOSTests",
            exclude: ["__Snapshots__"]
        ),
    ]
)
