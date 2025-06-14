import SwiftUI

@main
struct AIHelperApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

/// Корневое представление: временно показывает AssistView
struct RootView: View {
    var body: some View {
        NavigationStack {
            AssistView()
        }
    }
} 