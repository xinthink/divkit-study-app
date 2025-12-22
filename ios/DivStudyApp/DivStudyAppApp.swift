import SwiftUI
import DivStudyAppFeature

@main
struct DivStudyAppApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                List {
                    Section("Integration Examples") {
                        NavigationLink("Baseline: Hello World", destination: BaselineView())
                        NavigationLink("Module A: Dynamic Form", destination: ModuleAView())
                    }
                }
                .navigationTitle("DivKit Study Labs")
            }
        }
    }
}
