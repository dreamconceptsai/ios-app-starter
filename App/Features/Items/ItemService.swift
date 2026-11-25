import Foundation

/// The contract the UI depends on. Views and view models never talk to the network directly.
protocol ItemService: Sendable {
    func fetchItems() async throws -> [TodoItem]
    func toggle(_ item: TodoItem) async throws -> TodoItem
}

/// Live implementation backed by the REST API.
struct RemoteItemService: ItemService {
    let client: any HTTPClient

    func fetchItems() async throws -> [TodoItem] {
        let endpoint = Endpoint<[TodoItem]>(
            path: "todos",
            queryItems: [URLQueryItem(name: "_limit", value: "20")]
        )
        return try await client.send(endpoint)
    }

    func toggle(_ item: TodoItem) async throws -> TodoItem {
        let body = try JSONEncoder().encode(["completed": !item.completed])
        let endpoint = Endpoint<TodoItem>(
            path: "todos/\(item.id)",
            method: .patch,
            body: body
        )
        return try await client.send(endpoint)
    }
}

/// In-memory implementation for previews and tests. Configure it to succeed, fail or be slow.
struct MockItemService: ItemService {
    var items: [TodoItem] = TodoItem.samples
    var fetchError: APIError? = nil
    var toggleError: APIError? = nil
    var delay: Duration = .zero

    func fetchItems() async throws -> [TodoItem] {
        if delay > .zero {
            try await Task.sleep(for: delay)
        }
        if let fetchError {
            throw fetchError
        }
        return items
    }

    func toggle(_ item: TodoItem) async throws -> TodoItem {
        if let toggleError {
            throw toggleError
        }
        var updated = item
        updated.completed.toggle()
        return updated
    }
}
