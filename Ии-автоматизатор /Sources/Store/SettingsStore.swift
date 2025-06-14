import Foundation
import SwiftUI

/// Override for application color scheme
enum ColorSchemeOverride: String, Codable, CaseIterable, Identifiable {
    case system, light, dark
    var id: String { rawValue }
}

/// Manages loading and saving LLM-related settings using UserDefaults
final class SettingsStore: ObservableObject {
    @Published var useLocalFirst: Bool = true {
        didSet { save() }
    }
    @Published var manualOverride: Bool = false {
        didSet { save() }
    }
    @Published var useFoundationModels: Bool = false {
        didSet { save() }
    }
    @Published var apiKey: String = KeychainService.shared.getAPIKey() ?? "" {
        didSet {
            do {
                try KeychainService.shared.setAPIKey(apiKey)
            } catch {
                print("Failed to save API key to Keychain: \(error)")
            }
        }
    }
    @Published var selectedLocalModelPath: String? = nil {
        didSet { save() }
    }
    @Published var n8nBaseURL: String = "http://127.0.0.1:5678" {
        didSet { save() }
    }
    @Published var n8nApiKey: String = "" {
        didSet { save() }
    }
    
    // MARK: - Theming
    @Published var accentColorHex: String = "#007AFF" {
        didSet { save() }
    }
    @Published var colorSchemeOverride: ColorSchemeOverride = .system {
        didSet { save() }
    }
    /// Computed accent color from hex
    var accentColor: Color {
        Color(hex: accentColorHex)
    }
    /// Computed preferred ColorScheme for SwiftUI
    var preferredColorScheme: ColorScheme? {
        switch colorSchemeOverride {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }
    
    private let storageKey = "llmSettings"
    
    private struct Settings: Codable {
        var useLocalFirst: Bool
        var manualOverride: Bool
        var useFoundationModels: Bool
        var selectedLocalModelPath: String?
        var n8nBaseURL: String
        var n8nApiKey: String
        var accentColorHex: String
        var colorSchemeOverride: ColorSchemeOverride
    }
    
    init() {
        load()
    }
    
    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        if let decoded = try? JSONDecoder().decode(Settings.self, from: data) {
            useLocalFirst = decoded.useLocalFirst
            manualOverride = decoded.manualOverride
            useFoundationModels = decoded.useFoundationModels
            selectedLocalModelPath = decoded.selectedLocalModelPath
            n8nBaseURL = decoded.n8nBaseURL
            n8nApiKey = decoded.n8nApiKey
            accentColorHex = decoded.accentColorHex
            colorSchemeOverride = decoded.colorSchemeOverride
        }
    }
    
    private func save() {
        let settings = Settings(useLocalFirst: useLocalFirst,
                                manualOverride: manualOverride,
                                useFoundationModels: useFoundationModels,
                                selectedLocalModelPath: selectedLocalModelPath,
                                n8nBaseURL: n8nBaseURL,
                                n8nApiKey: n8nApiKey,
                                accentColorHex: accentColorHex,
                                colorSchemeOverride: colorSchemeOverride)
        if let data = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(data, forKey: storageKey)
            // Also save individual n8n settings for service
            UserDefaults.standard.set(n8nBaseURL, forKey: "n8nBaseURL")
            UserDefaults.standard.set(n8nApiKey, forKey: "n8nApiKey")
            UserDefaults.standard.set(useFoundationModels, forKey: "useFoundationModels")
        }
    }
} 