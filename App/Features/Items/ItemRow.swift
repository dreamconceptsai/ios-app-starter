import SwiftUI

struct ItemRow: View {
    let item: TodoItem
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: item.completed ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(item.completed ? Color.accentColor : Color.secondary)
                    .contentTransition(.symbolEffect(.replace))
            }
            // Borderless lets the button receive taps inside a List row with a NavigationLink.
            .buttonStyle(.borderless)
            .accessibilityLabel(item.completed ? "Mark as open" : "Mark as done")

            Text(item.title)
                .strikethrough(item.completed, color: .secondary)
                .foregroundStyle(item.completed ? .secondary : .primary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    List {
        ItemRow(item: TodoItem.samples[0]) {}
        ItemRow(item: TodoItem.samples[1]) {}
    }
}
