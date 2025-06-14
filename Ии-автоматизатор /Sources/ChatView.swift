import SwiftUI
import SwiftData

struct ChatView: View {
    @EnvironmentObject var settingsStore: SettingsStore
    @Environment(\.modelContext) private var modelContext
    @State private var prompt: String = ""
    @State private var responseText: String = ""
    @State private var isStreaming: Bool = false
    @State private var streamTask: Task<(), Never>? = nil

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                TextField("Enter prompt...", text: $prompt)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(isStreaming)
                if isStreaming {
                    Button(action: cancel) {
                        Image(systemName: "xmark.circle.fill")
                    }
                    .help("Cancel generation")
                } else {
                    Button(action: send) {
                        Text("Send")
                    }
                    .disabled(
                        prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                        (settingsStore.manualOverride ? settingsStore.selectedLocalModelPath == nil :
                            (settingsStore.useLocalFirst && settingsStore.selectedLocalModelPath == nil))
                    )
                }
            }
            .padding([.leading, .trailing])

            Divider()

            ScrollView {
                Text(responseText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
            .background(Color.secondary.opacity(0.05))
            .cornerRadius(8)
            .padding([.leading, .trailing, .bottom])
        }
        .navigationTitle("AI Chat")
    }

    private func send() {
        // Сохраняем новую беседу и пользовательское сообщение
        let conversation = Conversation()
        let userMessage = Message(content: prompt, isUser: true)
        conversation.messages.append(userMessage)
        modelContext.insert(conversation)
        try? modelContext.save()
        // Запускаем генерацию
        responseText = ""
        isStreaming = true
        streamTask?.cancel()
        streamTask = Task {
            var fullResponse = ""
            do {
                for try await token in (settingsStore.useLocalFirst && settingsStore.selectedLocalModelPath != nil ?
                    LLMService.shared.generateTokens(prompt: prompt, modelPath: settingsStore.selectedLocalModelPath!) :
                    CloudLLMService.shared.generateTokens(prompt: prompt)) {
                    await MainActor.run {
                        responseText += token
                        fullResponse += token
                    }
                }
                // Сохраняем ответ ассистента
                await MainActor.run {
                    let assistantMessage = Message(content: fullResponse, isUser: false)
                    conversation.messages.append(assistantMessage)
                    try? modelContext.save()
                }
            } catch {
                print("Streaming error: \(error)")
            }
            await MainActor.run {
                isStreaming = false
            }
        }
    }

    private func cancel() {
        streamTask?.cancel()
        isStreaming = false
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        // Mock settings and static model path
        let settingsStore = SettingsStore()
        settingsStore.selectedLocalModelPath = "/path/to/model.gguf"
        // Note: LLMService.shared will not be called during preview
        return ChatView()
            .environmentObject(settingsStore)
    }
} 