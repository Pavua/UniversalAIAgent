import SwiftUI

#if os(macOS)
@main
struct AIHelperMacOSApp: App {
    @StateObject private var projectStore = ProjectStore()
    @StateObject private var settingsStore = SettingsStore()
    @StateObject private var modelStore = ModelStore()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(projectStore)
                .environmentObject(settingsStore)
                .environmentObject(modelStore)
                .accentColor(settingsStore.accentColor)
                .preferredColorScheme(settingsStore.preferredColorScheme)
        }
        // Отдельное окно диалога с LLM
        WindowGroup("LLM Chat") {
            ChatView()
                .environmentObject(settingsStore)
        }
        // SwiftData container for Templates and Chat History
        .modelContainer(for: [Template.self, Conversation.self, Message.self])
        Settings {
            SettingsView()
                .environmentObject(settingsStore)
        }
        .modelContainer(for: [Template.self, Conversation.self, Message.self])
    }
}
#endif 