import Foundation
import SwiftUI

enum AppTabIcon: Equatable {
    case system(String)
    case asset(String)
}

enum AppTab: String, CaseIterable, Identifiable {
    case analysis
    case bills
    case calendar
    case savings
    case more

    var id: String { rawValue }

    var title: String {
        switch self {
        case .analysis: "明细"
        case .bills: "账单"
        case .calendar: "日历记账"
        case .savings: "攒钱"
        case .more: "更多"
        }
    }

    var icon: AppTabIcon {
        switch self {
        case .analysis: .system("list.bullet.rectangle.portrait")
        case .bills: .system("doc")
        case .calendar: .system("plus")
        case .savings: .asset("PiggyBankTab")
        case .more: .system("square.grid.2x2")
        }
    }
}

enum TransactionKind: String, CaseIterable, Identifiable {
    case expense = "支出"
    case income = "收入"

    var id: String { rawValue }
}

enum LedgerCategory: String, CaseIterable, Identifiable {
    case dining = "餐饮"
    case shopping = "购物"
    case daily = "日用"
    case transport = "交通"
    case housing = "住房"
    case communication = "通信"
    case clothing = "服饰"
    case medical = "医疗"
    case salary = "工资"
    case bonus = "奖金"
    case sideJob = "副业"
    case gift = "红包"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .dining: "fork.knife"
        case .shopping: "bag"
        case .daily: "basket"
        case .transport: "bus"
        case .housing: "house"
        case .communication: "iphone"
        case .clothing: "tshirt"
        case .medical: "cross.case"
        case .salary: "banknote"
        case .bonus: "sparkles"
        case .sideJob: "briefcase"
        case .gift: "gift"
        }
    }

    var color: Color {
        switch self {
        case .dining: Color(red: 0.96, green: 0.37, blue: 0.32)
        case .shopping: Color(red: 0.91, green: 0.31, blue: 0.50)
        case .daily: Color(red: 0.95, green: 0.67, blue: 0.24)
        case .transport: Color(red: 0.22, green: 0.60, blue: 0.70)
        case .housing: Color(red: 0.39, green: 0.55, blue: 0.86)
        case .communication: Color(red: 0.39, green: 0.70, blue: 0.62)
        case .clothing: Color(red: 0.65, green: 0.43, blue: 0.77)
        case .medical: Color(red: 0.91, green: 0.38, blue: 0.43)
        case .salary: Color(red: 0.23, green: 0.67, blue: 0.47)
        case .bonus: Color(red: 0.94, green: 0.63, blue: 0.18)
        case .sideJob: Color(red: 0.29, green: 0.58, blue: 0.78)
        case .gift: Color(red: 0.85, green: 0.35, blue: 0.48)
        }
    }
}

struct Transaction: Identifiable, Hashable {
    let id: UUID
    var kind: TransactionKind
    var amount: Double
    var category: LedgerCategory
    var account: String
    var merchant: String
    var note: String
    var date: Date
    var isPrivate: Bool

    init(
        id: UUID = UUID(),
        kind: TransactionKind,
        amount: Double,
        category: LedgerCategory,
        account: String,
        merchant: String,
        note: String = "",
        date: Date,
        isPrivate: Bool = true
    ) {
        self.id = id
        self.kind = kind
        self.amount = amount
        self.category = category
        self.account = account
        self.merchant = merchant
        self.note = note
        self.date = date
        self.isPrivate = isPrivate
    }
}

struct DailySummary: Identifiable {
    let date: Date
    let income: Double
    let expense: Double
    var id: Date { date }
    var balance: Double { income - expense }
}
