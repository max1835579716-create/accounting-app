import SwiftUI

struct CalendarLedgerView: View {
    let store: AppStore
    let onAddTransaction: () -> Void
    @State private var shownMonth = Date.now

    var body: some View {
        CollapsingScrollView(isCollapsed: collapseBinding) {
            VStack(spacing: 18) {
                header
                calendarCard
                shortcuts
                dailyDetails
            }
            .padding(.horizontal, 18)
            .padding(.top, 12)
            .padding(.bottom, 32)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Menu {
                Button("日常账本", action: {})
                Button("家庭账本", action: {})
                Button("旅行账本", action: {})
            } label: {
                HStack(spacing: 8) {
                    Text("日常账本").font(.largeTitle.bold()).foregroundStyle(.primary)
                    Image(systemName: "chevron.down").font(.caption.bold())
                }
            }
            Text("快速回看，也能随手记下").font(.subheadline).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var calendarCard: some View {
        VStack(spacing: 14) {
            HStack {
                Button { changeMonth(-1) } label: { Image(systemName: "chevron.left") }
                Spacer()
                Text(shownMonth.formatted(.dateTime.year().month(.wide))).font(.headline)
                Spacer()
                Button { changeMonth(1) } label: { Image(systemName: "chevron.right") }
            }
            MonthCalendarView(month: shownMonth, selectedDate: selectedDateBinding, summary: store.dailySummary)
            Divider()
            HStack {
                Label("本月收入 \(store.totalIncome.currencyText)", systemImage: "arrow.down.left").foregroundStyle(.green)
                Spacer()
                Label("本月支出 \(store.totalExpense.currencyText)", systemImage: "arrow.up.right").foregroundStyle(.red)
            }
            .font(.caption.weight(.semibold))
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var shortcuts: some View {
        HStack(spacing: 10) {
            ShortcutButton(title: "小票", symbol: "receipt")
            ShortcutButton(title: "资产", symbol: "wallet.bifold")
            ShortcutButton(title: "清单", symbol: "checklist")
            ShortcutButton(title: "预算", symbol: "gauge.with.dots.needle.50percent")
        }
    }

    private var dailyDetails: some View {
        let items = store.transactions(on: store.selectedDate)
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(store.selectedDate.formatted(.dateTime.month().day().weekday(.wide))).font(.title3.bold())
                    Text(items.isEmpty ? "这一天还没有账单" : "共 \(items.count) 笔")
                        .font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                Text(store.dailySummary(on: store.selectedDate).balance.currencyText)
                    .font(.headline).foregroundStyle(.secondary)
            }

            if items.isEmpty {
                Button(action: onAddTransaction) {
                    Label("记下第一笔", systemImage: "plus.circle.fill")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
            } else {
                ForEach(items) { TransactionRow(transaction: $0) }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 20))
    }

    private func changeMonth(_ value: Int) {
        shownMonth = Calendar.current.date(byAdding: .month, value: value, to: shownMonth) ?? shownMonth
    }

    private var collapseBinding: Binding<Bool> {
        Binding(get: { store.isTabBarCollapsed }, set: { store.isTabBarCollapsed = $0 })
    }

    private var selectedDateBinding: Binding<Date> {
        Binding(get: { store.selectedDate }, set: { store.selectedDate = $0 })
    }
}

private struct ShortcutButton: View {
    let title: String
    let symbol: String
    var body: some View {
        Button(action: {}) {
            VStack(spacing: 7) {
                Image(systemName: symbol).font(.title3)
                Text(title).font(.caption.weight(.medium))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 64)
        }
        .buttonStyle(.plain)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
    }
}
