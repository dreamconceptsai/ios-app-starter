import Testing
@testable import StarterApp

@MainActor
@Suite("ItemsViewModel")
struct ItemsViewModelTests {
    @Test("Loading succeeds and fills the list")
    func loadSuccess() async {
        let viewModel = ItemsViewModel(service: MockItemService())

        await viewModel.load()

        #expect(viewModel.loadState == .loaded)
        #expect(viewModel.items == TodoItem.samples)
    }

    @Test("Loading failure shows an error message")
    func loadFailure() async {
        let viewModel = ItemsViewModel(service: MockItemService(fetchError: .httpStatus(500)))

        await viewModel.load()

        #expect(viewModel.loadState == .failed("The server returned an error (HTTP 500)."))
        #expect(viewModel.items.isEmpty)
    }

    @Test("Filter narrows the visible items", arguments: [
        (ItemsViewModel.Filter.all, 5),
        (ItemsViewModel.Filter.open, 3),
        (ItemsViewModel.Filter.done, 2),
    ])
    func filtering(filter: ItemsViewModel.Filter, expectedCount: Int) async {
        let viewModel = ItemsViewModel(service: MockItemService())
        await viewModel.load()

        viewModel.filter = filter

        #expect(viewModel.visibleItems.count == expectedCount)
    }

    @Test("Search is case-insensitive and ignores surrounding spaces")
    func search() async {
        let viewModel = ItemsViewModel(service: MockItemService())
        await viewModel.load()

        viewModel.searchText = "  CLAUDE "

        #expect(viewModel.visibleItems.map(\.id) == [2])
    }

    @Test("Toggling flips completion")
    func toggleSuccess() async throws {
        let viewModel = ItemsViewModel(service: MockItemService())
        await viewModel.load()
        let item = try #require(viewModel.items.first(where: { $0.id == 2 }))

        await viewModel.toggle(item)

        #expect(viewModel.items.first(where: { $0.id == 2 })?.completed == true)
        #expect(viewModel.alertMessage == nil)
    }

    @Test("Toggling rolls back and alerts when the server fails")
    func toggleFailureRollsBack() async throws {
        let viewModel = ItemsViewModel(service: MockItemService(toggleError: .transport("offline")))
        await viewModel.load()
        let item = try #require(viewModel.items.first(where: { $0.id == 2 }))

        await viewModel.toggle(item)

        #expect(viewModel.items.first(where: { $0.id == 2 })?.completed == false)
        #expect(viewModel.alertMessage == "Network problem: offline")

        #expect(viewModel.isShowingAlert)
        viewModel.isShowingAlert = false
        #expect(viewModel.alertMessage == nil)
    }
}
