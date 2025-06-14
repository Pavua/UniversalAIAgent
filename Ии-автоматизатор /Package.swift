// swift-tools-version:5.10
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
        .package(url: "https://github.com/getsentry/sentry-swift.git", from: "8.0.0")
    ],
    targets: [
        .executableTarget(
            name: "AIHelperMacOS",
            dependencies: [
                "Yams",
                .product(name: "llama", package: "llama.swift"),
                .product(name: "KeychainAccess", package: "KeychainAccess"),
                .product(name: "GRDB", package: "GRDB.swift"),
                .product(name: "Sentry", package: "sentry-swift"),
            ],
            path: "Sources"
        )
    ]
) 