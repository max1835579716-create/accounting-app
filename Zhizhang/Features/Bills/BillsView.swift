import SwiftUI

struct BillsView: View {
    let store: AppStore

    private var grouped: [(Date, [Transaction])] {
        Dictionary(grouping: store.transactions) { Calendar.current.startOfDay(for: $0.date) }
            .sorted { $0.key > $1.key }
    }

    var body: some View {
        CollapsingScrollView(isCollapsed: collapseBinding) {
            VStack(spacing: 20) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("账单").font(.largeTitle.bold())
                        Text(Date.now.formatted(.dateTime.year().month(.wide))).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button(action: {}) { Image(systemName: "magnifyingglass") }.buttonStyle(.bordered)
                    Button(action: {}) { Image(systemName: "line.3.horizontal.decrease") }.buttonStyle(.bordered)
                }

                HStack(spacing: 10) {
                    SummaryTile(title: "收入", value: store.totalIncome, color: .green)
                    SummaryTile(title: "支出", value: store.totalExpense, color: .red)
                    SummaryTile(title: "结余", value: store.balance, color: .indigo)
                }

                ForEach(grouped, id: \.0) { date, items in
                    VStack(spacing: 0) {
                        HStack {
                            Text(date.formatted(.dateTime.month().day().weekday(.wide))).font(.headline)
                            Spacer()
                            Text(items.reduce(0) { $0 + ($1.kind == .income ? $1.amount : -$1.amount) }.currencyText)
                                .font(.subheadline.weight(.semibold))
                        }
                        .padding(.bottom, 8)
                        ForEach(items) { TransactionRow(transaction: $0) }
                    }
                    .padding(16)
                    .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 20))
                }
            }
            .padding(18)
            .padding(.bottom, 24)
        }
    }

    private var collapseBinding: Binding<Bool> {
        Binding(get: { store.isTabBarCollapsed }, set: { store.isTabBarCollapsed = $0 })
    }
}

struct SummaryTile: View {
    let title: String
    let value: Double
    let color: Color
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            Text(value.currencyText).font(.headline).foregroundStyle(color).lineLimit(1).minimumScaleFactor(0.65)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(color.opacity(0.08), in: RoundedRectangle(cornerRadius: 14))
    }
}

struct TransactionRow: View {
    let transaction: Transaction
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: transaction.category.symbol)
                .foregroundStyle(transaction.category.color)
                .frame(width: 38, height: 38)
                .background(transaction.category.color.opacity(0.12), in: Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.category.rawValue).fontWeight(.medium)
                Text(transaction.merchant).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(transaction.kind == .expense ? "-" : "+")\(transaction.amount.currencyText)")
                    .fontWeight(.semibold)
                    .foregroundStyle(transaction.kind == .expense ? Color.primary : .green)
                Text(transaction.account).font(.caption2).foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 10)
        .overlay(alignment: .bottom) { Divider().padding(.leading, 50) }
    }
}
