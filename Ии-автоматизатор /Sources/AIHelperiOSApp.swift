#if os(iOS)
import SwiftUI

@main
struct AIHelperiOSApp: App {
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
    }
}
#endif 