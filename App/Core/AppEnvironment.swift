import Foundation
import Observation

/// Dependency container. Every service the app uses is created here, so you can
/// swap real implementations for mocks in previews, unit tests and UI tests.
@MainActor
@Observable
final class AppEnvironment {
    let config: AppConfig
    let itemService: any ItemService

    init(config: AppConfig, itemService: any ItemService) {
        self.config = config
        self.itemService = itemService
    }

    /// Picks live or mock dependencies based on launch arguments.
    /// UI tests launch the app with `-uiTesting` so they never hit the network.
    static func bootstrap(arguments: [String] = ProcessInfo.processInfo.arguments) -> AppEnvironment {
        if arguments.contains(LaunchArgument.uiTesting) {
            return .preview
        }
        let config = AppConfig.current
        let client = APIClient(baseURL: config.apiBaseURL)
        return AppEnvironment(config: config, itemService: RemoteItemService(client: client))
    }

    /// Mock-backed environment for SwiftUI previews and UI tests.
    static var preview: AppEnvironment {
        AppEnvironment(config: .preview, itemService: MockItemService())
    }
}

enum LaunchArgument {
    static let uiTesting = "-uiTesting"
}
