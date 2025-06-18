import SwiftData
import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: SettingsModel
    
    var body: some View {
        NavigationView {
            Form {
                Section("API Настройки") {
                    HStack {
                        Text("OpenAI API Key:")
                        Spacer()
                        SecureField("sk-...", text: $settings.openaiApiKey)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    HStack {
                        Text("Telegram Bot Token:")
                        Spacer()
                        SecureField("1234567890:ABC...", text: $settings.telegramBotToken)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                
                Section("LM Studio") {
                    HStack {
                        Text("URL:")
                        Spacer()
                        TextField("http://localhost:1234", text: $settings.lmStudioURL)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    HStack {
                        Text("Модель:")
                        Spacer()
                        TextField("llama-3.2-3b-instruct", text: $settings.lmStudioModel)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                
                Section("Локальный LLM") {
                    HStack {
                        Text("Путь к модели:")
                        Spacer()
                        TextField("/path/to/model", text: $settings.localModelPath)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
            }
            .navigationTitle("Настройки")
        }
    }
}

#Preview { SettingsView(settings: SettingsModel.shared) }
