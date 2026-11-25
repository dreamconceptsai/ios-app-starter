import Foundation

struct TodoItem: Identifiable, Codable, Hashable, Sendable {
    let id: Int
    var title: String
    var completed: Bool
}

extension TodoItem {
    /// Sample data for previews, unit tests and UI tests.
    static let samples: [TodoItem] = [
        TodoItem(id: 1, title: "Set up the Xcode project", completed: true),
        TodoItem(id: 2, title: "Connect Claude Agent in Xcode", completed: false),
        TodoItem(id: 3, title: "Write the first feature", completed: false),
        TodoItem(id: 4, title: "Add unit tests", completed: true),
        TodoItem(id: 5, title: "Ship to TestFlight", completed: false),
    ]
}
