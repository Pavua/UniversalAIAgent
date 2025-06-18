import Foundation
import Combine

class SettingsModel: ObservableObject {
    static let shared = SettingsModel()
    
    @Published var openaiApiKey: String = ""
    @Published var telegramBotToken: String = ""
    @Published var lmStudioURL: String = "http://localhost:1234"
    @Published var lmStudioModel: String = "llama-3.2-3b-instruct"
    @Published var localModelPath: String = ""
    
    private init() {
        loadSettings()
    }
    
    private func loadSettings() {
        openaiApiKey = UserDefaults.standard.string(forKey: "openai_api_key") ?? ""
        telegramBotToken = UserDefaults.standard.string(forKey: "telegram_bot_token") ?? ""
        lmStudioURL = UserDefaults.standard.string(forKey: "lm_studio_url") ?? "http://localhost:1234"
        lmStudioModel = UserDefaults.standard.string(forKey: "lm_studio_model") ?? "llama-3.2-3b-instruct"
        localModelPath = UserDefaults.standard.string(forKey: "local_model_path") ?? ""
    }
    
    func saveSettings() {
        UserDefaults.standard.set(openaiApiKey, forKey: "openai_api_key")
        UserDefaults.standard.set(telegramBotToken, forKey: "telegram_bot_token")
        UserDefaults.standard.set(lmStudioURL, forKey: "lm_studio_url")
        UserDefaults.standard.set(lmStudioModel, forKey: "lm_studio_model")
        UserDefaults.standard.set(localModelPath, forKey: "local_model_path")
    }
}

struct LLMSource: Codable, Identifiable, Hashable {
    enum LLMType: String, Codable, CaseIterable, Identifiable {
        case lmstudio, docker, mlx, openai
        var id: String { rawValue }
    }
    var id: UUID = UUID()
    var name: String
    var type: LLMType
    var url: String
    var isEnabled: Bool
}
