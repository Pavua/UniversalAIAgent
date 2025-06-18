import SwiftUI

struct LocalLLMView: View {
    @State private var prompt: String = ""
    @State private var answer: String = ""
    @State private var attributedAnswer: AttributedString = ""
    @State private var isLoading = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Prompt")
            TextEditor(text: $prompt)
                .frame(height: 120)
                .border(Color.gray)

            HStack {
                Button(action: { isLoading ? cancel() : generate() }) {
                    Text(isLoading ? "Cancel" : "Generate")
                }
                .disabled(prompt.isEmpty && !isLoading)
            }

            Text("Answer")
            ScrollViewReader { proxy in
                ScrollView {
                    Text(attributedAnswer)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .id("BOTTOM")
                }
                .border(Color.gray)
                .onChange(of: answer) { new in
                    if let md = try? AttributedString(markdown: new) {
                        attributedAnswer = md
                    } else {
                        attributedAnswer = AttributedString(new)
                    }
                    proxy.scrollTo("BOTTOM", anchor: .bottom)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func generate() {
        isLoading = true; answer = ""
        LocalLLMService.shared.generate(prompt: prompt) { result in
            DispatchQueue.main.async {
                switch result {
                case let .success(text):
                    answer = ""
                    let tokens = text.split(separator: " ")
                    for (idx, token) in tokens.enumerated() {
                        DispatchQueue.main.asyncAfter(deadline: .now() + Double(idx) * 0.04) {
                            answer += token + " "
                        }
                    }
                case let .failure(err):
                    answer = "Error: \(err.localizedDescription)"
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(answer.split(separator: " ").count) * 0.04) {
                    isLoading = false
                }
            }
        }
    }

    private func cancel() {
        isLoading = false
        answer += "\n[Cancelled]"
    }
}

#Preview { LocalLLMView() }
