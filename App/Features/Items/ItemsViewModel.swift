import Foundation
import Observation

/// Holds the state for the Items screen. All UI logic lives here so it can be unit tested.
@MainActor
@Observable
final class ItemsViewModel {
    enum LoadState: Equatable {
        case idle
        case loading
        case loaded
        case failed(String)
    }

    enum Filter: String, CaseIterable, Identifiable {
        case all
        case open
        case done

        var id: Self { self }

        var title: String {
            switch self {
            case .all: "All"
            case .open: "Open"
            case .done: "Done"
            }
        }
    }

    private(set) var items: [TodoItem] = []
    private(set) var loadState: LoadState = .idle
    private(set) var alertMessage: String?
    var filter: Filter = .all
    var searchText = ""

    private let service: any ItemService

    init(service: any ItemService) {
        self.service = service
    }

    /// Items after applying the filter and search text.
    var visibleItems: [TodoItem] {
        items.filter { matchesFilter($0) && matchesSearch($0) }
    }

    var openCount: Int {
        items.filter { !$0.completed }.count
    }

    func load() async {
        loadState = .loading
        do {
            items = try await service.fetchItems()
            loadState = .loaded
        } catch {
            loadState = .failed(Self.message(for: error))
        }
    }

    /// Optimistically flips the item, then rolls back if the server call fails.
    func toggle(_ item: TodoItem) async {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        let original = items[index]
        items[index].completed.toggle()

        do {
            let updated = try await service.toggle(original)
            replace(updated)
        } catch {
            replace(original)
            alertMessage = Self.message(for: error)
        }
    }

    /// Drives `.alert(isPresented:)`. Setting it to false clears the message.
    var isShowingAlert: Bool {
        get { alertMessage != nil }
        set { if !newValue { alertMessage = nil } }
    }

    // MARK: - Private

    private func replace(_ item: TodoItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = item
        }
    }

    private func matchesFilter(_ item: TodoItem) -> Bool {
        switch filter {
        case .all: true
        case .open: !item.completed
        case .done: item.completed
        }
    }

    private func matchesSearch(_ item: TodoItem) -> Bool {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        return query.isEmpty || item.title.localizedCaseInsensitiveContains(query)
    }

    private static func message(for error: Error) -> String {
        (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
    }
}
