import SwiftUI
import DivKit
import VGSL
import os

/// Module A: Dynamic Form - State Management Black Box Lab
///
/// This view demonstrates the "State Management Black Box" challenge when integrating
/// DivKit with SwiftUI. It exposes the architectural friction of maintaining two parallel
/// state machines: SwiftUI's declarative @State and DivKit's internal variable storage.
///
/// The implementation showcases:
/// 1. Bidirectional state synchronization between native and DivKit components
/// 2. The "State Ping-Pong" problem and how to prevent infinite recursion
/// 3. The imperative bridge code required for synchronization
/// 4. Performance costs of variable observation on the main thread
public struct ModuleAView: View {

    // MARK: - DivKit Integration State

    @State private var divViewSource: DivViewSource?
    @State private var errorMessage: String?
    @State private var variablesStorage: DivVariablesStorage?
    @State private var observerDisposable: Disposable?

    // MARK: - Shared Logical State

    /// The single source of truth for the "liked" state across both SwiftUI and DivKit layers.
    /// In an ideal declarative world, only this would exist. In reality, DivKit maintains
    /// its own parallel state machine that we must manually synchronize with this.
    @State private var isLiked: Bool = false

    /// Previous value of isLiked to detect changes manually
    @State private var previousIsLiked: Bool = false

    // MARK: - Synchronization Control (Circuit Breakers)

    /// Deduplication flag: Prevents recursive updates from DivKit observer
    /// When true, skips native→DivKit sync to prevent infinite loops
    @State private var isUpdatingFromDivKit: Bool = false

    /// Deduplication flag: Prevents recursive updates from native onChange
    /// When true, skips DivKit→native sync to prevent infinite loops
    @State private var isUpdatingFromNative: Bool = false

    // MARK: - Constants

    private enum Constants {
        static let likeVariableName = "is_liked"
        static let cardId = "module_a_dynamic_form"
        static let flagResetDelay: Duration = .milliseconds(50)
    }

    // MARK: - Logger

    private let logger = Logger(subsystem: "com.divkit.moduleA", category: "State Sync")

    // MARK: - Initialization

    public init() {}

    // MARK: - Body

    public var body: some View {
        VStack(spacing: 0) {
            if let source = divViewSource {
                // MARK: - DivKit Section (Top Half)
                ScrollView(.vertical) {
                    DivHostingView(
                        divkitComponents: DivKitComponentsManager.shared.divKitComponents,
                        source: source,
                        debugParams: DebugParams(isDebugInfoEnabled: false)
                    )
                    .frame(minHeight: 350)
                }

                Divider()
                    .padding(.vertical, 8)

                // MARK: - Native SwiftUI Section (Bottom Half)
                VStack(spacing: 16) {
                    Text("Native SwiftUI Control")
                        .font(.headline)

                    HStack(spacing: 12) {
                        Text("Like Status:")
                            .font(.body)

                        Toggle("", isOn: $isLiked)
                            .labelsHidden()

                        Text(isLiked ? "❤️ Liked" : "🤍 Not Liked")
                            .font(.body)
                    }
                    .padding(.horizontal)

                    Text("SwiftUI State: \(isLiked ? "TRUE" : "FALSE")")
                        .font(.caption)
                        .foregroundColor(isLiked ? .red : .gray)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))

            } else if let error = errorMessage {
                // MARK: - Error State
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 48))
                        .foregroundColor(.orange)
                    Text("Error Loading Module A")
                        .font(.headline)
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            } else {
                // MARK: - Loading State
                VStack(spacing: 12) {
                    ProgressView()
                    Text("Loading Module A...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationTitle("Module A: Dynamic Form")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadData()
        }
        .task {
            // Monitor for changes to isLiked and sync to DivKit
            while true {
                try? await Task.sleep(for: .milliseconds(50))
                if isLiked != previousIsLiked {
                    previousIsLiked = isLiked
                    syncNativeToDivKit(isLiked)
                }
            }
        }
        .onDisappear {
            cleanup()
        }
    }

    // MARK: - Data Loading

    /// Loads the DivKit card from JSON and initializes the observer for state synchronization.
    @MainActor
    private func loadData() async {
        do {
            let jsonData = try MockDataLoader.loadJSON(for: .moduleA)
            guard let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
                errorMessage = "Invalid JSON format"
                self.logger.error("Failed to parse JSON as dictionary")
                return
            }

            // Create DivKit source from JSON
            divViewSource = DivViewSource(
                kind: .json(json),
                cardId: DivCardID(rawValue: Constants.cardId)
            )

            self.logger.log("✅ DivKit card loaded successfully")

            // CRITICAL: Extract variables storage AFTER source creation
            // Otherwise, the storage hasn't been initialized yet
            variablesStorage = DivKitComponentsManager.shared
                .divKitComponents
                .variablesStorage

            // Setup bidirectional synchronization
            setupDivKitObserver()

        } catch {
            errorMessage = error.localizedDescription
            self.logger.error("Failed to load data: \(error.localizedDescription)")
        }
    }

    // MARK: - Synchronization: Native → DivKit

    /// Syncs SwiftUI state to DivKit's internal variable storage.
    ///
    /// Flow:
    /// 1. User toggles native switch → isLiked changes
    /// 2. Monitoring task detects change → this function called
    /// 3. Check if we're already handling a DivKit update (prevent ping-pong)
    /// 4. Set circuit breaker flag
    /// 5. Call storage.update() to push to DivKit
    /// 6. After delay, reset flag
    ///
    /// The delay allows DivKit to finish processing before we accept new updates.
    @MainActor
    private func syncNativeToDivKit(_ value: Bool) {
        // CIRCUIT BREAKER: Prevent recursion from DivKit observer
        guard !isUpdatingFromDivKit else {
            self.logger.log("🚫 Skipped Native→DivKit (deduplicated by isUpdatingFromDivKit flag)")
            return
        }

        guard let storage = variablesStorage else {
            self.logger.warning("⚠️ Variables storage not ready for sync")
            return
        }

        self.logger.log("➡️ Syncing Native→DivKit: \(value)")

        // Set flag to prevent DivKit→Native callback from firing
        isUpdatingFromNative = true

        // IMPERATIVE BRIDGE: Update DivKit's internal variable
        // This is the "black box" effect - we must manually push state via an imperative API
        storage.update(
            cardId: DivCardID(rawValue: Constants.cardId),
            name: DivVariableName(rawValue: Constants.likeVariableName),
            value: value ? "1" : "0"  // DivKit bool vars use "1" and "0" as strings
        )

        // Reset flag after delay to allow DivKit to process
        Task {
            try? await Task.sleep(for: Constants.flagResetDelay)
            self.isUpdatingFromNative = false
        }
    }

    // MARK: - Synchronization: DivKit → Native

    /// Sets up an observer for DivKit variable changes and syncs back to SwiftUI state.
    ///
    /// This registers a callback that fires whenever any DivKit variable changes.
    /// We filter for our specific card and variable, then query the storage for the updated value.
    @MainActor
    private func setupDivKitObserver() {
        guard let storage = variablesStorage else { return }

        // Register observer for ALL variable changes
        // Note: This demonstrates the challenge of integrating DivKit's callback-based observer
        // pattern with SwiftUI's state-based approach on a struct (value type)
        let disposable = storage.addObserver { [unowned storage] _ in
            // Observer callback - fires when ANY variable changes in ANY card
            // We query our specific variable to see if it changed

            // Query the current value of our variable
            let updatedValue = storage.getVariableValue(
                cardId: DivCardID(rawValue: Constants.cardId),
                name: DivVariableName(rawValue: Constants.likeVariableName)
            )

            // Convert the DivVariableValue to boolean
            let boolValue: Bool
            switch updatedValue {
            case .bool(let b):
                boolValue = b
            case .color(_), .dict(_), .integer(_), .number(_), .string(_), .url(_), .array(_):
                boolValue = false
            case .none:
                boolValue = false
            @unknown default:
                boolValue = false
            }

            self.logger.log("👁️ DivKit observer: is_liked = \(boolValue)")
            self.syncDivKitToNative(boolValue)
        }

        observerDisposable = disposable
        self.logger.log("👁️ DivKit observer registered successfully")
    }

    /// Syncs DivKit state back to SwiftUI's state.
    ///
    /// Flow:
    /// 1. User taps DivKit button → action executes: set_variable?name=is_liked&value=!is_liked
    /// 2. DivKit updates internal variable
    /// 3. Observer callback fires
    /// 4. This function called
    /// 5. Check if we're already handling a native update (prevent ping-pong)
    /// 6. Set circuit breaker flag
    /// 7. Update SwiftUI @State (triggers monitoring task, but we skip with flag)
    /// 8. After delay, reset flag
    @MainActor
    private func syncDivKitToNative(_ value: Bool) {
        // CIRCUIT BREAKER: Prevent recursion from native onChange
        guard !isUpdatingFromNative else {
            self.logger.log("🚫 Skipped DivKit→Native (deduplicated by isUpdatingFromNative flag)")
            return
        }

        self.logger.log("⬅️ Syncing DivKit→Native: \(value)")

        // Set flag to prevent Native→DivKit monitoring task from firing
        isUpdatingFromDivKit = true

        // Update SwiftUI state (this triggers monitoring task, but we'll skip it with our flag)
        previousIsLiked = value  // Update previous value first to prevent re-trigger
        isLiked = value

        // Reset flag after delay
        Task {
            try? await Task.sleep(for: Constants.flagResetDelay)
            self.isUpdatingFromDivKit = false
        }
    }

    // MARK: - Cleanup

    /// Disposes of the observer to prevent memory leaks.
    /// Called when the view disappears.
    private func cleanup() {
        // Dispose of the observer to clean up and remove callbacks
        observerDisposable?.dispose()
        self.logger.log("🧹 Observer disposed (cleanup)")
        observerDisposable = nil
        variablesStorage = nil
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ModuleAView()
    }
}
