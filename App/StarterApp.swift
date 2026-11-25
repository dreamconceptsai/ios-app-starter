import SwiftUI

/// App entry point. Builds the dependency container once and hands it to the view tree.
@main
struct StarterApp: App {
    @State private var environment = AppEnvironment.bootstrap()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(environment)
        }
    }
}
