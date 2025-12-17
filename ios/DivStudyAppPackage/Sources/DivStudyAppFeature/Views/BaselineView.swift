import SwiftUI

public struct BaselineView: View {
    @State private var jsonData: Data?
    @State private var errorMessage: String?

    public init() {}

    public var body: some View {
        VStack {
            if let data = jsonData {
                DivKitWrapper(jsonData: data, cardId: "baseline")
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
        .onAppear { loadData() }
    }

    private func loadData() {
        do {
            jsonData = try MockDataLoader.loadJSON(for: .baseline)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
