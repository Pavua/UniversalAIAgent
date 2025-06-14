import Foundation
import KeychainAccess

/// A service for secure storage of API key in Keychain
final class KeychainService {
    static let shared = KeychainService()
    private let keychain = Keychain(service: Bundle.main.bundleIdentifier ?? "AIHelperMacOS")
    private let apiKeyKey = "openAIAPIKey"
    private init() {}

    func setAPIKey(_ key: String) throws {
        try keychain.set(key, key: apiKeyKey)
    }

    func getAPIKey() -> String? {
        return try? keychain.get(apiKeyKey)
    }
} 
