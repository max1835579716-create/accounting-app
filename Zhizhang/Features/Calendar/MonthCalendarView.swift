import SwiftUI

struct MonthCalendarView: View {
    let month: Date
    @Binding var selectedDate: Date
    let summary: (Date) -> DailySummary

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 5), count: 7)
    private let weekdaySymbols = ["日", "一", "二", "三", "四", "五", "六"]

    var body: some View {
        VStack(spacing: 10) {
            LazyVGrid(columns: columns, spacing: 5) {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol).font(.caption2.weight(.semibold)).foregroundStyle(.secondary).frame(height: 22)
                }
                ForEach(Array(days.enumerated()), id: \.offset) { _, date in
                    if let date {
                        dayCell(date)
                    } else {
                        Color.clear.frame(height: 62)
                    }
                }
            }
        }
    }

    private func dayCell(_ date: Date) -> some View {
        let item = summary(date)
        let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)
        return Button {
            selectedDate = date
        } label: {
            VStack(spacing: 3) {
                Text(date.formatted(.dateTime.day()))
                    .font(.subheadline.weight(isSelected ? .bold : .medium))
                Text(item.income > 0 ? "+\(compact(item.income))" : " ")
                    .font(.system(size: 8, weight: .medium))
                    .foregroundStyle(.green)
                Text(item.expense > 0 ? "-\(compact(item.expense))" : " ")
                    .font(.system(size: 8, weight: .medium))
                    .foregroundStyle(.red)
            }
            .frame(maxWidth: .infinity, minHeight: 62)
            .background(isSelected ? Color.accentColor.opacity(0.13) : Color(.tertiarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 11))
            .overlay {
                RoundedRectangle(cornerRadius: 11)
                    .stroke(isSelected ? Color.accentColor : .clear, lineWidth: 1.5)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(date.formatted(date: .long, time: .omitted))，收入 \(item.income.currencyText)，支出 \(item.expense.currencyText)")
    }

    private var days: [Date?] {
        let calendar = Calendar.current
        guard let range = calendar.range(of: .day, in: .month, for: month),
              let start = calendar.dateInterval(of: .month, for: month)?.start else { return [] }
        let leading = calendar.component(.weekday, from: start) - 1
        let dates = range.compactMap { calendar.date(byAdding: .day, value: $0 - 1, to: start) }
        return Array(repeating: nil, count: leading) + dates
    }

    private func compact(_ value: Double) -> String {
        if value >= 1_000 { return String(format: "%.1fk", value / 1_000) }
        return String(format: value.rounded() == value ? "%.0f" : "%.1f", value)
    }
}
