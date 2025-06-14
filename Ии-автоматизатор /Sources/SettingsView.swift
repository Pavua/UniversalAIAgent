import SwiftUI
import SwiftData

struct SettingsView: View {
    @EnvironmentObject var settingsStore: SettingsStore
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Template.name, animation: .default) private var templates: [Template]
    @State private var templatesJSON: String = ""
    @State private var showTemplatesError: Bool = false
    @State private var templatesErrorText: String = ""

    var body: some View {
        Form {
            Section(header: Text("LLM Settings")) {
                Toggle("Use Local First", isOn: $settingsStore.useLocalFirst)
                Toggle("Disable Cloud Fallback", isOn: $settingsStore.manualOverride)
                Toggle("Use on-device LLM (FoundationModels)", isOn: $settingsStore.useFoundationModels)
                SecureField("OpenAI API Key", text: $settingsStore.apiKey)
            }
            Section(header: Text("n8n Settings")) {
                TextField("n8n Base URL", text: $settingsStore.n8nBaseURL)
                    .textContentType(.URL)
#if os(iOS)
                    .autocapitalization(.none)
#endif
                SecureField("n8n API Key", text: $settingsStore.n8nApiKey)
            }
            Section(header: Text("Appearance")) {
                ColorPicker("Accent Color", selection: Binding(
                    get: { settingsStore.accentColor },
                    set: { newColor in
                        if let hex = newColor.toHex() {
                            settingsStore.accentColorHex = hex
                        }
                    }
                ))
                Picker("Theme", selection: $settingsStore.colorSchemeOverride) {
                    ForEach(ColorSchemeOverride.allCases) { mode in
                        Text(mode.rawValue.capitalized).tag(mode)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            Section(header: Text("Templates (JSON)")) {
                VStack(alignment: .leading) {
                    Text("Edit code templates as JSON array of objects { \"name\": String, \"content\": String }")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextEditor(text: $templatesJSON)
                        .font(.system(.body, design: .monospaced))
                        .frame(minHeight: 150)
                    HStack {
                        Button("Reload Templates") {
                            do {
                                let data = try JSONEncoder().encode(templates.map { TemplateDTO(id: $0.id, name: $0.name, content: $0.content) })
                                templatesJSON = String(data: data, encoding: .utf8) ?? ""
                            } catch {
                                templatesErrorText = error.localizedDescription
                                showTemplatesError = true
                            }
                        }
                        Button("Save Templates") {
                            do {
                                let dtos = try JSONDecoder().decode([TemplateDTO].self, from: Data(templatesJSON.utf8))
                                // Replace all
                                for t in templates { modelContext.delete(t) }
                                for dto in dtos {
                                    let t = Template(id: dto.id, name: dto.name, content: dto.content)
                                    modelContext.insert(t)
                                }
                            } catch {
                                templatesErrorText = error.localizedDescription
                                showTemplatesError = true
                            }
                        }
                        .disabled(templatesJSON.isEmpty)
                    }
                }
            }
        }
        .padding()
        .frame(width: 400)
        .onAppear {
            // Initialize JSON with current templates
            do {
                let data = try JSONEncoder().encode(templates.map { TemplateDTO(id: $0.id, name: $0.name, content: $0.content) })
                templatesJSON = String(data: data, encoding: .utf8) ?? ""
            } catch {
                templatesErrorText = error.localizedDescription
                showTemplatesError = true
            }
        }
        .alert("Templates Error", isPresented: $showTemplatesError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(templatesErrorText)
        }
    }

    struct TemplateDTO: Identifiable, Codable {
        var id: UUID
        var name: String
        var content: String
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(SettingsStore())
            .modelContainer(for: [Template.self])
    }
} 