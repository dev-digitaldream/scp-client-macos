// swift-tools-version: 5.9
// Package.swift pour Swift Package Manager

import PackageDescription

let package = Package(
    name: "SCPClient",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "SCPClient",
            targets: ["SCPClient"]
        )
    ],
    dependencies: [],
    targets: [
        // Cible principale Swift
        .executableTarget(
            name: "SCPClient",
            dependencies: ["SCPClientBridge"],
            path: "SCPClient/Sources",
            exclude: ["Services/SCPSession.cpp", "Services/SCPSession.h"],
            resources: [
                .process("Resources")
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),

        // Bridge Objective-C++
        .target(
            name: "SCPClientBridge",
            dependencies: [],
            path: "SCPClient/Sources/Services",
            sources: ["SCPSessionBridge.mm", "SCPSession.cpp"],
            publicHeadersPath: ".",
            cxxSettings: [
                .headerSearchPath("."),
                .headerSearchPath("/opt/homebrew/include"),
                .headerSearchPath("/usr/local/include"),
            ],
            linkerSettings: [
                .linkedLibrary("ssh2"),
                .linkedLibrary("ssl"),
                .linkedLibrary("crypto"),
            ]
        )
    ],
    cxxLanguageStandard: .cxx17
)
