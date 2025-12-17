import SwiftUI
import DivKit

/// SwiftUI wrapper for DivKit's UIView-based DivView
/// Implements Code Snippet 2.2 from research documentation
public struct DivKitWrapper: UIViewRepresentable {

    let jsonData: Data
    let cardId: String

    public init(jsonData: Data, cardId: String = "baseline_card") {
        self.jsonData = jsonData
        self.cardId = cardId
    }

    // MARK: - UIViewRepresentable Protocol

    public func makeUIView(context: Context) -> DivView {
        let components = DivKitComponentsManager.shared.divKitComponents
        let divView = DivView(divKitComponents: components)
        updateDivView(divView, with: jsonData)
        return divView
    }

    public func updateUIView(_ uiView: DivView, context: Context) {
        updateDivView(uiView, with: jsonData)
    }

    // MARK: - Data Parsing

    private func updateDivView(_ divView: DivView, with data: Data) {
        Task { @MainActor in
            do {
                // Parse JSON data into dictionary
                guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    print("[DivKitWrapper] Parse error: Invalid JSON format")
                    return
                }

                // Set the source using the modern API
                await divView.setSource(
                    DivViewSource(
                        kind: .json(json),
                        cardId: DivCardID(rawValue: cardId)
                    )
                )
            } catch {
                print("[DivKitWrapper] Parse error: \(error)")
            }
        }
    }
}
