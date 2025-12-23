import SwiftUI
import Combine

public final class ThemeManager: ObservableObject {
    public enum Theme: String, CaseIterable {
        case light
        case dark
    }

    @Published public var currentTheme: Theme = .light

    public init() {}

    public func toggleTheme() {
        currentTheme = currentTheme == .light ? .dark : .light
    }
}