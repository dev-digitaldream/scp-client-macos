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
            exclude: [
                "Services/SCPSession.cpp",
                "Services/SCPSession.h",
                "Services/SCPSessionBridge.mm",
                "Services/SCPSessionBridge.h"
            ],
            resources: [
                .process("../Assets.xcassets")
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
                .unsafeFlags([
                    "-I/opt/homebrew/include",
                    "-I/opt/homebrew/Cellar/libssh2/1.11.1/include"
                ])
            ],
            linkerSettings: [
                .linkedLibrary("ssh2"),
                .linkedLibrary("ssl"),
                .linkedLibrary("crypto"),
                .unsafeFlags([
                    "-L/opt/homebrew/lib",
                    "-L/usr/local/lib"
                ]),
            ]
        )
    ],
    cxxLanguageStandard: .cxx17
)
