import SwiftUI
import DivKit

public struct BaselineView: View {
    @State private var divViewSource: DivViewSource?
    @State private var errorMessage: String?
    @EnvironmentObject private var themeManager: ThemeManager

    public init() {}

    public var body: some View {
        VStack {
            HStack {
                Spacer()
                Toggle("Dark Mode", isOn: Binding(
                    get: { themeManager.currentTheme == .dark },
                    set: { _ in themeManager.toggleTheme() }
                ))
                .fixedSize(horizontal: true, vertical: false)
                .padding(.trailing)
            }

            Divider()
              .padding()

            Text("Native Views")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.bottom, 8)
            Text("This a native text")
                .font(.subheadline)
                .foregroundColor(.primary)
                .padding(.bottom, 16)

            Divider()
              .padding()
            Text("DivKit Views")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.bottom, 8)
            if let source = divViewSource {
                DivHostingView(
                    divkitComponents: DivKitComponentsManager.shared.divKitComponents,
                    source: source,
                    debugParams: DebugParams(isDebugInfoEnabled: false)
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = errorMessage {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 48))
                        .foregroundColor(.orange)
                    Text("Error Loading DivKit Content")
                        .font(.headline)
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            } else {
                ProgressView("Loading DivKit...")
            }
        }
        .navigationTitle("Integration Baseline")
        .task {
            await loadData()
        }
    }

    @MainActor
    private func loadData() async {
        do {
            let jsonData = try MockDataLoader.loadJSON(for: .baseline)
            guard let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
                errorMessage = "Invalid JSON format"
                return
            }

            divViewSource = DivViewSource(
                kind: .json(json),
                cardId: DivCardID(rawValue: "baseline")
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
