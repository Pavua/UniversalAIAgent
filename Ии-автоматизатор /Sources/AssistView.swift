import SwiftUI
import AVFoundation
import Speech

/// View for voice/text prompts to generate code or projects
struct AssistView: View {
    @State private var promptText: String = ""
    @State private var isRecording: Bool = false
    @State private var audioEngine = AVAudioEngine()
    @State private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    @State private var recognitionTask: SFSpeechRecognitionTask?
    @State private var log: String = ""
    @State private var isRunning: Bool = false
    @State private var outputFolder: URL? = nil

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                TextField("Enter prompt or speak...", text: $promptText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: toggleRecording) {
                    Image(systemName: isRecording ? "mic.fill" : "mic")
                        .font(.title)
                }
                .padding(.leading)
            }
            .padding()

            HStack {
                Button(isRunning ? "Cancel" : "Generate") {
                    if isRunning { /* TODO: cancel */ }
                    else { runGeneration() }
                }
                .disabled(promptText.isEmpty)
                if isRunning { ProgressView().padding(.leading) }
            }
            .padding()

            ScrollView {
                Text(log)
                    .font(.system(.body, design: .monospaced))
                    .padding()
            }
        }
        .padding()
        .navigationTitle("Assist")
    }

    private func toggleRecording() {
        // TODO: Implement speech recognition
    }

    private func runGeneration() {
        // TODO: Use CodeGenerationService to stream code generation based on promptText and save to outputFolder
    }
}

struct AssistView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AssistView()
        }
    }
} 