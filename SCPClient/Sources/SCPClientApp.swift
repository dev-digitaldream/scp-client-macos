//
//  SCPClientApp.swift
//  SCP Client for macOS
//
//  Point d'entrée de l'application
//

import SwiftUI

@main
struct SCPClientApp: App {
    @StateObject private var connectionManager = ConnectionManager()
    @StateObject private var connectionService = ConnectionService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(connectionManager)
                .environmentObject(connectionService)
                .frame(minWidth: 900, minHeight: 600)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("Nouvelle connexion") {
                    // Action handled in ContentView
                }
                .keyboardShortcut("n", modifiers: [.command])
            }
        }
    }
}
