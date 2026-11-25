import Foundation

/// Static configuration. Point `apiBaseURL` at your own backend when you're ready.
///
/// Never put secret API keys (OpenAI, Anthropic, Stripe secret keys, etc.) in an iOS app:
/// anyone can extract them from the binary. Call your own server, and keep keys there.
struct AppConfig: Sendable {
    let apiBaseURL: URL
    let repositoryURL: URL

    /// Demo backend: JSONPlaceholder is a free fake REST API, so the app works out of the box.
    static let current = AppConfig(
        apiBaseURL: URL(string: "https://jsonplaceholder.typicode.com")!,
        repositoryURL: URL(string: "https://github.com/dreamconceptsai/ios-app-starter")!
    )

    static let preview = AppConfig(
        apiBaseURL: URL(string: "https://example.invalid")!,
        repositoryURL: URL(string: "https://github.com/dreamconceptsai/ios-app-starter")!
    )
}
