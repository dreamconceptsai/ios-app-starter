import SwiftUI

/// Top-level tab layout. Add new top-level features as tabs here.
struct RootView: View {
    @Environment(AppEnvironment.self) private var environment
    @AppStorage(StorageKey.appearance) private var appearance: Appearance = .system

    var body: some View {
        TabView {
            ItemsView(service: environment.itemService)
                .tabItem { Label("Items", systemImage: "checklist") }

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
        .preferredColorScheme(appearance.colorScheme)
    }
}

#Preview {
    RootView()
        .environment(AppEnvironment.preview)
}
