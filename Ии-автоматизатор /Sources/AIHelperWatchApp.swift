#if os(watchOS)
import SwiftUI

@main
struct AIHelperWatchApp: App {
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