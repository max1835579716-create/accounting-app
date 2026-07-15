import SwiftUI

struct AddTransactionSheet: View {
    @Environment(\.dismiss) private var dismiss
    let store: AppStore
    @State private var kind: TransactionKind = .expense
    @State private var category: LedgerCategory = .dining
    @State private var amount = ""
    @State private var account = "支付宝"
    @State private var merchant = ""
    @State private var note = ""
    @State private var date: Date

    init(store: AppStore, initialDate: Date) {
        self.store = store
        _date = State(initialValue: initialDate)
    }

    var body: some View {
        VStack(spacing: 14) {
            header
            Picker("类型", selection: $kind) {
                ForEach(TransactionKind.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)

            categoryGrid
            inputBar
            AmountKeypad(value: $amount, onComplete: save)
        }
        .padding(.horizontal, 18)
        .padding(.bottom, 12)
        .onChange(of: kind) { _, newValue in
            category = newValue == .expense ? .dining : .salary
        }
    }

    private var header: some View {
        HStack {
            Button { dismiss() } label: { Image(systemName: "xmark") }
                .accessibilityLabel("关闭")
            Spacer()
            Text("记一笔").font(.headline)
            Spacer()
            Button(action: save) { Image(systemName: "checkmark") }
                .disabled(numericAmount <= 0)
                .accessibilityLabel("保存")
                .accessibilityIdentifier("save-transaction")
        }
        .font(.title3.weight(.semibold))
        .padding(.top, 4)
    }

    private var categoryGrid: some View {
        let categories = kind == .expense ? Array(LedgerCategory.allCases.prefix(8)) : [.salary, .bonus, .sideJob, .gift]
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
            ForEach(categories) { item in
                Button {
                    category = item
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: item.symbol).font(.title3)
                        Text(item.rawValue).font(.caption)
                    }
                    .foregroundStyle(category == item ? Color.accentColor : Color.primary)
                    .frame(maxWidth: .infinity, minHeight: 58)
                    .background(category == item ? Color.accentColor.opacity(0.12) : .clear, in: RoundedRectangle(cornerRadius: 14))
                    .overlay { RoundedRectangle(cornerRadius: 14).stroke(category == item ? Color.accentColor : Color.clear, lineWidth: 1.2) }
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var inputBar: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: category.symbol).foregroundStyle(category.color)
                TextField("商家或备注", text: $merchant)
                Text(numericAmount.currencyText).font(.title3.bold()).foregroundStyle(numericAmount > 0 ? Color.primary : .secondary)
            }
            HStack(spacing: 16) {
                Menu(account) {
                    ForEach(["支付宝", "微信", "银行卡", "现金", "信用卡"], id: \.self) { value in
                        Button(value) { account = value }
                    }
                }
                DatePicker("", selection: $date, displayedComponents: .date).labelsHidden()
                TextField("补充说明", text: $note).font(.caption)
                Button(action: {}) { Image(systemName: "camera") }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
    }

    private var numericAmount: Double { Double(amount) ?? 0 }

    private func save() {
        guard numericAmount > 0 else { return }
        store.addTransaction(
            kind: kind,
            amount: numericAmount,
            category: category,
            account: account,
            merchant: merchant,
            note: note,
            date: date
        )
        dismiss()
    }
}
