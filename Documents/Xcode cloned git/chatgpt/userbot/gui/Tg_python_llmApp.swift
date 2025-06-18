import SwiftData
import SwiftUI
import FirebaseCore
import FirebaseCrashlytics

@main
struct Tg_python_llmApp: App {
    init() {
        FirebaseApp.configure()
    }

    private let modelContainer: ModelContainer = {
        do {
            return try ModelContainer(for: Chat.self, Message.self)
        } catch {
            fatalError("Failed to initialize model container: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(modelContainer)
                .preferredColorScheme(UserDefaults.standard.bool(forKey: "USE_DARK_MODE") ? .dark : .light)
                .background(.ultraThinMaterial)
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        .windowToolbarStyle(UnifiedCompactWindowToolbarStyle())
    }
}
