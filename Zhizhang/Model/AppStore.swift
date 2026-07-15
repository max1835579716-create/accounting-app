import Foundation
import Observation

@MainActor
@Observable
final class AppStore {
    var selectedTab: AppTab = .calendar
    var transactions: [Transaction]
    var isTabBarCollapsed = false
    var selectedDate = Calendar.current.startOfDay(for: .now)

    init(transactions: [Transaction] = []) {
        self.transactions = transactions.sorted { $0.date > $1.date }
    }

    var totalIncome: Double {
        transactions.filter { $0.kind == .income }.reduce(0) { $0 + $1.amount }
    }

    var totalExpense: Double {
        transactions.filter { $0.kind == .expense }.reduce(0) { $0 + $1.amount }
    }

    var balance: Double { totalIncome - totalExpense }

    func transactions(on date: Date) -> [Transaction] {
        transactions.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }

    func dailySummary(on date: Date) -> DailySummary {
        let items = transactions(on: date)
        return DailySummary(
            date: Calendar.current.startOfDay(for: date),
            income: items.filter { $0.kind == .income }.reduce(0) { $0 + $1.amount },
            expense: items.filter { $0.kind == .expense }.reduce(0) { $0 + $1.amount }
        )
    }

    var dailySummaries: [DailySummary] {
        let grouped = Dictionary(grouping: transactions) { Calendar.current.startOfDay(for: $0.date) }
        return grouped.keys.sorted().map(dailySummary)
    }

    func addTransaction(
        kind: TransactionKind,
        amount: Double,
        category: LedgerCategory,
        account: String,
        merchant: String,
        note: String,
        date: Date
    ) {
        guard amount > 0 else { return }
        transactions.insert(
            Transaction(
                kind: kind,
                amount: amount,
                category: category,
                account: account,
                merchant: merchant.isEmpty ? category.rawValue : merchant,
                note: note,
                date: date
            ),
            at: 0
        )
        selectedDate = Calendar.current.startOfDay(for: date)
    }
}

extension AppStore {
    static var demo: AppStore {
        let calendar = Calendar.current
        let month = calendar.dateInterval(of: .month, for: .now)?.start ?? .now
        func day(_ value: Int, hour: Int = 12) -> Date {
            calendar.date(byAdding: DateComponents(day: value - 1, hour: hour), to: month) ?? .now
        }

        let store = AppStore(transactions: [
            Transaction(kind: .income, amount: 12_000, category: .salary, account: "银行卡", merchant: "本月工资", date: day(2, hour: 9)),
            Transaction(kind: .income, amount: 680, category: .sideJob, account: "支付宝", merchant: "设计稿收入", date: day(8, hour: 19)),
            Transaction(kind: .expense, amount: 68.8, category: .dining, account: "微信", merchant: "周末晚餐", date: day(3, hour: 18)),
            Transaction(kind: .expense, amount: 328, category: .shopping, account: "支付宝", merchant: "生活用品", date: day(5, hour: 15)),
            Transaction(kind: .expense, amount: 1_200, category: .housing, account: "银行卡", merchant: "物业与水电", date: day(9, hour: 10)),
            Transaction(kind: .expense, amount: 2_190, category: .shopping, account: "信用卡", merchant: "家庭采购", date: day(12, hour: 16)),
            Transaction(kind: .expense, amount: 500, category: .transport, account: "支付宝", merchant: "交通充值", date: day(14, hour: 8))
        ])
        if ProcessInfo.processInfo.arguments.contains("--calendar") {
            store.selectedTab = .calendar
        }
        return store
    }
}
