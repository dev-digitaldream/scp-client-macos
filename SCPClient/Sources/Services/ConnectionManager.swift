//
//  ConnectionManager.swift
//  SCP Client for macOS
//
//  Gestionnaire pour sauvegarder/charger les connexions favorites
//

import Foundation

class ConnectionManager: ObservableObject {
    @Published var savedConnections: [Connection] = []

    private let userDefaults = UserDefaults.standard
    private let connectionsKey = "SavedConnections"

    init() {
        loadConnections()
    }

    func loadConnections() {
        guard let data = userDefaults.data(forKey: connectionsKey) else {
            return
        }

        do {
            savedConnections = try JSONDecoder().decode([Connection].self, from: data)
        } catch {
            print("Failed to load connections: \(error)")
        }
    }

    func saveConnections() {
        do {
            let data = try JSONEncoder().encode(savedConnections)
            userDefaults.set(data, forKey: connectionsKey)
        } catch {
            print("Failed to save connections: \(error)")
        }
    }

    func addConnection(_ connection: Connection) {
        savedConnections.append(connection)
        saveConnections()
    }

    func updateConnection(_ connection: Connection) {
        if let index = savedConnections.firstIndex(where: { $0.id == connection.id }) {
            savedConnections[index] = connection
            saveConnections()
        }
    }

    func deleteConnection(_ connection: Connection) {
        savedConnections.removeAll { $0.id == connection.id }
        saveConnections()
    }

    func markConnectionUsed(_ connection: Connection) {
        if let index = savedConnections.firstIndex(where: { $0.id == connection.id }) {
            savedConnections[index].updateLastUsed()
            saveConnections()
        }
    }
}
