import SwiftUI

struct ItemsView: View {
    @State private var viewModel: ItemsViewModel

    init(service: any ItemService) {
        _viewModel = State(initialValue: ItemsViewModel(service: service))
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Items")
                .navigationDestination(for: TodoItem.self) { item in
                    ItemDetailView(item: item)
                }
                .searchable(text: $viewModel.searchText, prompt: "Search items")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Picker("Filter", selection: $viewModel.filter) {
                            ForEach(ItemsViewModel.Filter.allCases) { filter in
                                Text(filter.title).tag(filter)
                            }
                        }
                        .pickerStyle(.menu)
                        .accessibilityIdentifier("filterPicker")
                    }
                }
                .task {
                    if viewModel.loadState == .idle {
                        await viewModel.load()
                    }
                }
                .refreshable {
                    await viewModel.load()
                }
                .alert("Something went wrong", isPresented: $viewModel.isShowingAlert) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text(viewModel.alertMessage ?? "")
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.items.isEmpty {
            emptyState
        } else {
            List {
                Section {
                    ForEach(viewModel.visibleItems) { item in
                        NavigationLink(value: item) {
                            ItemRow(item: item) {
                                Task { await viewModel.toggle(item) }
                            }
                        }
                        .accessibilityIdentifier("item-\(item.id)")
                    }
                } footer: {
                    Text("\(viewModel.openCount) open of \(viewModel.items.count)")
                }
            }
            .accessibilityIdentifier("itemsList")
            .overlay {
                if viewModel.visibleItems.isEmpty {
                    ContentUnavailableView.search(text: viewModel.searchText)
                }
            }
        }
    }

    @ViewBuilder
    private var emptyState: some View {
        switch viewModel.loadState {
        case .idle, .loading:
            ProgressView("Loading…")
        case .loaded:
            ContentUnavailableView("No items yet", systemImage: "tray")
        case .failed(let message):
            ContentUnavailableView {
                Label("Couldn't load items", systemImage: "wifi.exclamationmark")
            } description: {
                Text(message)
            } actions: {
                Button("Try Again") {
                    Task { await viewModel.load() }
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
}

#Preview("Loaded") {
    ItemsView(service: MockItemService())
}

#Preview("Error") {
    ItemsView(service: MockItemService(fetchError: .httpStatus(500)))
}

#Preview("Slow network") {
    ItemsView(service: MockItemService(delay: .seconds(3)))
}
