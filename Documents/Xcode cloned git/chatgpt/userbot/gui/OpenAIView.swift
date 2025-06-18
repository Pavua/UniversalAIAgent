import MarkdownUI
import SwiftUI

struct OpenAIView: View {
    @State private var prompt: String = ""
    @State private var answer: AttributedString = ""
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
                    MarkdownEnhancedView(content: answer.description)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(4)
                        .id("BOTTOM")
                }
                .border(Color.gray)
                .onChange(of: answer) { _ in
                    proxy.scrollTo("BOTTOM", anchor: .bottom)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func generate() {
        isLoading = true
        answer = ""
        OpenAIBridge.shared.generate(prompt: prompt,
                                     onToken: { token in
                                         var attr = answer
                                         attr += AttributedString(token)
                                         answer = attr
                                     }, onComplete: { _ in
                                         DispatchQueue.main.async { isLoading = false }
                                     })
    }

    private func cancel() {
        OpenAIBridge.shared.cancel()
        isLoading = false
    }
}

#Preview { OpenAIView() }
