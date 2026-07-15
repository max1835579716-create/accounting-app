import SwiftUI

private enum AddTransactionDestination: String, Identifiable {
    case datePicker

    var id: String { rawValue }
}

struct AddTransactionSheet: View {
    @Environment(\.dismiss) private var dismiss
    let store: AppStore
    @State private var kind: TransactionKind = .expense
    @State private var category: LedgerCategory = .dining
    @State private var amount = ""
    @State private var account = "支付宝"
    @State private var merchant = ""
    @State private var note = ""
    @State private var selectedDate: Date
    @State private var draftDate: Date
    @State private var destination: AddTransactionDestination?

    init(store: AppStore, initialDate: Date) {
        self.store = store
        _selectedDate = State(initialValue: initialDate)
        _draftDate = State(initialValue: initialDate)
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
            AmountKeypad(
                value: $amount,
                dateTitle: CompactDateTitle.text(for: selectedDate),
                onDateTap: openDatePicker,
                onComplete: save
            )
        }
        .padding(.horizontal, 18)
        .padding(.bottom, 12)
        .onChange(of: kind) { _, newValue in
            category = newValue == .expense ? .dining : .salary
        }
        .sheet(item: $destination) { _ in
            TransactionDatePickerSheet(
                selectedDate: $selectedDate,
                draftDate: $draftDate
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
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
                .fixedSize(horizontal: true, vertical: false)
                TextField("补充说明", text: $note)
                    .font(.caption)
                    .frame(maxWidth: .infinity)
                    .layoutPriority(1)
                    .accessibilityIdentifier("supplementary-note")
                Button(action: {}) { Image(systemName: "camera") }
                    .fixedSize()
                    .accessibilityIdentifier("camera-button")
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
            date: selectedDate
        )
        dismiss()
    }

    private func openDatePicker() {
        draftDate = selectedDate
        destination = .datePicker
    }
}

private struct TransactionDatePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedDate: Date
    @Binding var draftDate: Date

    var body: some View {
        NavigationStack {
            DatePicker(
                "交易日期",
                selection: $draftDate,
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .labelsHidden()
            .padding(.horizontal, 18)
            .navigationTitle("选择日期")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                        .accessibilityIdentifier("date-picker-cancel")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") {
                        selectedDate = draftDate
                        dismiss()
                    }
                    .accessibilityIdentifier("date-picker-done")
                }
            }
        }
    }
}
