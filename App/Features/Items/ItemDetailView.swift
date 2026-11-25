import SwiftUI

struct ItemDetailView: View {
    let item: TodoItem

    var body: some View {
        Form {
            Section("Title") {
                Text(item.title)
            }
            Section("Status") {
                Label(
                    item.completed ? "Done" : "Open",
                    systemImage: item.completed ? "checkmark.circle.fill" : "circle"
                )
            }
            Section("ID") {
                Text("\(item.id)")
                    .monospaced()
            }
        }
        .navigationTitle("Item")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ItemDetailView(item: TodoItem.samples[0])
    }
}
