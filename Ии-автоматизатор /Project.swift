import ProjectDescription

/// Tuist project definition for AIHelper
let project = Project(
    name: "AIHelper",
    organizationName: "com.yourorg",
    options: .options(automaticSchemesOptions: .enabled),
    packages: [], // SPM dependencies via Package.swift
    targets: [
        Target(
            name: "AIHelperMacOS",
            platform: .macOS,
            product: .app,
            bundleId: "com.yourorg.aihelper.macos",
            deploymentTarget: .macOS(targetVersion: "14.0"),
            infoPlist: .default,
            sources: ["Sources/**"],
            dependencies: []
        ),
        Target(
            name: "AIHelperiOS",
            platform: .iOS,
            product: .app,
            bundleId: "com.yourorg.aihelper.ios",
            deploymentTarget: .iOS(targetVersion: "17.0"),
            infoPlist: .default,
            sources: ["Sources/**"],
            dependencies: []
        ),
        Target(
            name: "AIHelperWatch",
            platform: .watchOS,
            product: .app,
            bundleId: "com.yourorg.aihelper.watchos",
            deploymentTarget: .watchOS(targetVersion: "9.0"),
            infoPlist: .default,
            sources: ["Sources/**"],
            dependencies: []
        ),
        Target(
            name: "AIHelperMacOSTests",
            platform: .macOS,
            product: .unitTests,
            bundleId: "com.yourorg.aihelper.macos.tests",
            deploymentTarget: .macOS(targetVersion: "14.0"),
            infoPlist: .default,
            sources: ["Tests/AIHelperMacOSTests/**"],
            dependencies: [
                .target(name: "AIHelperMacOS")
            ]
        ),
        Target(
            name: "AIHelperiOSTests",
            platform: .iOS,
            product: .unitTests,
            bundleId: "com.yourorg.aihelper.ios.tests",
            deploymentTarget: .iOS(targetVersion: "17.0"),
            infoPlist: .default,
            sources: ["Tests/AIHelperiOSTests/**"],
            dependencies: [
                .target(name: "AIHelperiOS")
            ]
        ),
        Target(
            name: "AIHelperWatchTests",
            platform: .watchOS,
            product: .unitTests,
            bundleId: "com.yourorg.aihelper.watchos.tests",
            deploymentTarget: .watchOS(targetVersion: "9.0"),
            infoPlist: .default,
            sources: ["Tests/AIHelperWatchOSTests/**"],
            dependencies: [
                .target(name: "AIHelperWatch")
            ]
        )
    ]
) 