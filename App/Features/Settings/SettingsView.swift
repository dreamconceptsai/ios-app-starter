import SwiftUI

enum Appearance: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: Self { self }

    var title: String {
        switch self {
        case .system: "System"
        case .light: "Light"
        case .dark: "Dark"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}

enum StorageKey {
    static let appearance = "appearance"
}

struct SettingsView: View {
    @Environment(AppEnvironment.self) private var environment
    @AppStorage(StorageKey.appearance) private var appearance: Appearance = .system

    var body: some View {
        NavigationStack {
            Form {
                Section("Appearance") {
                    Picker("Theme", selection: $appearance) {
                        ForEach(Appearance.allCases) { option in
                            Text(option.title).tag(option)
                        }
                    }
                }

                Section("About") {
                    LabeledContent("Version", value: Bundle.main.appVersion)
                    Link(destination: environment.config.repositoryURL) {
                        Label("Source code on GitHub", systemImage: "chevron.left.forwardslash.chevron.right")
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

extension Bundle {
    /// "1.0.0 (1)" from MARKETING_VERSION and CURRENT_PROJECT_VERSION.
    var appVersion: String {
        let version = infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
        let build = infoDictionary?["CFBundleVersion"] as? String ?? "—"
        return "\(version) (\(build))"
    }
}

#Preview {
    SettingsView()
        .environment(AppEnvironment.preview)
}
