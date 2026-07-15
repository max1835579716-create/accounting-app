import SwiftUI

struct AmountKeypad: View {
    @Binding var value: String
    let onComplete: () -> Void

    private let rows = [
        ["7", "8", "9", "今天"],
        ["4", "5", "6", "+"],
        ["1", "2", "3", "−"],
        [".", "0", "delete.left", "完成"]
    ]

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
                                    Text(key)
                                }
                            }
                            .font(key == "完成" ? .headline : .title3.weight(.medium))
                            .frame(maxWidth: .infinity, minHeight: 48)
                            .foregroundStyle(key == "完成" ? Color.white : Color.primary)
                            .background(key == "完成" ? Color.accentColor : Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14))
                        }
                        .buttonStyle(.plain)
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
        case "今天": break
        case ".": if !value.contains(".") { value = value.isEmpty ? "0." : value + "." }
        default:
            if value == "0" { value = key } else if value.count < 9 { value += key }
        }
    }
}
