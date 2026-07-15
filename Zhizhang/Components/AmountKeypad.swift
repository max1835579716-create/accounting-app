import SwiftUI

enum CompactDateTitle {
    static func text(for date: Date, calendar: Calendar = .current) -> String {
        if calendar.isDateInToday(date) {
            return "今天"
        }

        let components = calendar.dateComponents([.month, .day], from: date)
        guard let month = components.month, let day = components.day else {
            return ""
        }
        return "\(month).\(day)"
    }
}

struct AmountKeypad: View {
    @Binding var value: String
    let dateTitle: String
    let onDateTap: () -> Void
    let onComplete: () -> Void

    private let rows = [
        ["7", "8", "9", "date"],
        ["4", "5", "6", "+"],
        ["1", "2", "3", "−"],
        [".", "0", "delete.left", "完成"]
    ]

    init(
        value: Binding<String>,
        dateTitle: String = "今天",
        onDateTap: @escaping () -> Void = {},
        onComplete: @escaping () -> Void
    ) {
        _value = value
        self.dateTitle = dateTitle
        self.onDateTap = onDateTap
        self.onComplete = onComplete
    }

    var body: some View {
        VStack(spacing: 8) {
            ForEach(rows, id: \.self) { row in
                HStack(spacing: 8) {
                    ForEach(row, id: \.self) { key in
                        Button {
                            handle(key)
                        } label: {
                            Group {
                                if key == "delete.left" {
                                    Image(systemName: key)
                                } else {
                                    Text(key == "date" ? dateTitle : key)
                                        .lineLimit(1)
                                }
                            }
                            .font(key == "完成" ? .headline : .title3.weight(.medium))
                            .frame(maxWidth: .infinity, minHeight: 48)
                            .foregroundStyle(key == "完成" ? Color.white : Color.primary)
                            .background(key == "完成" ? Color.accentColor : Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14))
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier(key == "date" ? "transaction-date-button" : "keypad-\(key)")
                    }
                }
            }
        }
    }

    private func handle(_ key: String) {
        switch key {
        case "完成": onComplete()
        case "delete.left": if !value.isEmpty { value.removeLast() }
        case "+": break
        case "−": break
        case "date": onDateTap()
        case ".": if !value.contains(".") { value = value.isEmpty ? "0." : value + "." }
        default:
            if value == "0" { value = key } else if value.count < 9 { value += key }
        }
    }
}
