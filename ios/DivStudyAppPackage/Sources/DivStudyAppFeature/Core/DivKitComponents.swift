import DivKit
import UIKit

/// Manages DivKit lifecycle and configuration
public final class DivKitComponentsManager: @unchecked Sendable {
    public static let shared = DivKitComponentsManager()

    public let divKitComponents: DivKitComponents

    private init() {
        // Create basic DivKit components with default configuration
        // Note: DivKit 32.x simplified the initialization API
        self.divKitComponents = DivKitComponents()
    }
}
