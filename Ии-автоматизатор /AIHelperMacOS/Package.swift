// swift-tools-version:5.10
import PackageDescription

let package = Package(
    name: "AIHelperMacOS",
    platforms: [
        .macOS(.v14)
    ],
    dependencies: [
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.0.6"),
        .package(url: "https://github.com/alexrozanski/llama.swift.git", .upToNextMajor(from: "1.0.0"))
    ],
    targets: [
        .executableTarget(
            name: "AIHelperMacOS",
            dependencies: [
                "Yams",
                .product(name: "Llama", package: "llama.swift")
            ]
        )
    ]
) 