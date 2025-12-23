import SwiftUI
import DivStudyAppFeature

@main
struct DivStudyAppApp: App {
    @StateObject private var themeManager = DivStudyAppFeature.ThemeManager()

    var body: some Scene {
      WindowGroup {
        NavigationView {
          BaselineView()
        }
        .environmentObject(themeManager)
        .preferredColorScheme(themeManager.currentTheme == .dark ? .dark : .light)
      }
    }
}
