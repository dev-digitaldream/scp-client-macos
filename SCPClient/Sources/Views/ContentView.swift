//
//  ContentView.swift
//  SCP Client for macOS
//
//  Vue principale de l'application
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var connectionService: ConnectionService
    @EnvironmentObject var connectionManager: ConnectionManager

    @State private var showingConnectionSheet = false
    @State private var columnVisibility: NavigationSplitViewVisibility = .all

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            // Sidebar avec les connexions favorites
            SidebarView(showingConnectionSheet: $showingConnectionSheet)
                .frame(minWidth: 200)
        } detail: {
            // Vue principale
            if connectionService.isConnected {
                VSplitView {
                    FileExplorerView()
                        .frame(minHeight: 300)

                    TerminalView()
                        .frame(minHeight: 200, idealHeight: 300)
                }
            } else {
                WelcomeView(showingConnectionSheet: $showingConnectionSheet)
            }
        }
        .sheet(isPresented: $showingConnectionSheet) {
            ConnectionFormView()
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: {
                    columnVisibility = columnVisibility == .all ? .detailOnly : .all
                }) {
                    Image(systemName: "sidebar.left")
                }
            }

            if connectionService.isConnected {
                ToolbarItem {
                    Button(action: {
                        connectionService.disconnect()
                    }) {
                        Label("Déconnecter", systemImage: "power")
                    }
                }
            }
        }
    }
}

// Vue d'accueil
struct WelcomeView: View {
    @Binding var showingConnectionSheet: Bool

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "server.rack")
                .font(.system(size: 80))
                .foregroundColor(.blue)

            Text("SCP Client pour macOS")
                .font(.largeTitle)
                .bold()

            Text("Client SCP/SFTP simple et moderne")
                .font(.title3)
                .foregroundColor(.secondary)

            Button(action: { showingConnectionSheet = true }) {
                Label("Nouvelle connexion", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .padding()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            Divider()
                .padding(.vertical)

            VStack(alignment: .leading, spacing: 10) {
                FeatureRow(icon: "lock.shield", text: "Connexions SSH sécurisées")
                FeatureRow(icon: "folder", text: "Explorateur de fichiers dual-pane")
                FeatureRow(icon: "arrow.up.arrow.down", text: "Upload/Download avec progression")
                FeatureRow(icon: "star", text: "Gestion des favoris")
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 30)
                .foregroundColor(.blue)
            Text(text)
                .font(.body)
        }
    }
}
