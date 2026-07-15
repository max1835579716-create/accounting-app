import Charts
import SwiftUI

private enum AnalysisScope: String, CaseIterable, Identifiable {
    case personal = "个人"
    case family = "家庭"
    var id: String { rawValue }
}

private enum AnalysisMode: String, CaseIterable, Identifiable {
    case expense = "支出"
    case income = "收入"
    case budget = "预算"
    case cashflow = "收支趋势"
    case assets = "资产趋势"
    var id: String { rawValue }
    var symbol: String {
        switch self {
        case .expense: "cart"
        case .income: "yensign.circle"
        case .budget: "wallet.bifold"
        case .cashflow: "chart.line.uptrend.xyaxis"
        case .assets: "building.columns"
        }
    }
}

struct AnalysisView: View {
    let store: AppStore
    @State private var scope: AnalysisScope = .personal
    @State private var mode: AnalysisMode = .expense

    init(store: AppStore) {
        self.store = store
        if ProcessInfo.processInfo.arguments.contains("--cashflow") {
            _mode = State(initialValue: .cashflow)
        } else if ProcessInfo.processInfo.arguments.contains("--assets") {
            _mode = State(initialValue: .assets)
        }
    }

    var body: some View {
        CollapsingScrollView(isCollapsed: collapseBinding) {
            VStack(spacing: 20) {
                header
                monthPicker
                modePicker
                analysisBody
            }
            .padding(.horizontal, 18)
            .padding(.top, 12)
            .padding(.bottom, 28)
        }
    }

    private var collapseBinding: Binding<Bool> {
        Binding(get: { store.isTabBarCollapsed }, set: { store.isTabBarCollapsed = $0 })
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("明细").font(.largeTitle.bold())
                Text("让每一笔，都清清楚楚").font(.subheadline).foregroundStyle(.secondary)
            }
            Spacer()
            Picker("视角", selection: $scope) {
                ForEach(AnalysisScope.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)
            .frame(width: 138)
        }
    }

    private var monthPicker: some View {
        HStack {
            Button(action: {}) { Image(systemName: "chevron.left") }
            Spacer()
            Text(Date.now.formatted(.dateTime.year().month(.wide))).font(.headline)
            Spacer()
            Button(action: {}) { Image(systemName: "chevron.right") }
        }
        .padding(.horizontal, 16)
        .frame(height: 48)
        .glassPanel(cornerRadius: 18, interactive: true)
    }

    private var modePicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(AnalysisMode.allCases) { item in
                    Button {
                        withAnimation(.smooth) { mode = item }
                    } label: {
                        Label(item.rawValue, systemImage: item.symbol)
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 12)
                            .frame(height: 38)
                            .foregroundStyle(mode == item ? Color.white : Color.primary)
                            .background(mode == item ? Color.accentColor : Color(.secondarySystemGroupedBackground), in: Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    @ViewBuilder
    private var analysisBody: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "\(scope.rawValue)\(mode.rawValue)", action: "本月")
            switch mode {
            case .expense:
                categoryDonut(kind: .expense)
            case .income:
                categoryDonut(kind: .income)
            case .budget:
                budgetPanel
            case .cashflow:
                TrendChartView(store: store, kind: .cashflow)
            case .assets:
                TrendChartView(store: store, kind: .assets)
            }
        }
        .padding(18)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private func categoryDonut(kind: TransactionKind) -> some View {
        let data = categoryData(kind: kind)
        let total = data.reduce(0) { $0 + $1.amount }
        return VStack(spacing: 18) {
            ZStack {
                Chart(data) { item in
                    SectorMark(angle: .value("金额", item.amount), innerRadius: .ratio(0.62), angularInset: 2)
                        .foregroundStyle(item.category.color)
                        .cornerRadius(5)
                }
                .frame(height: 250)
                VStack(spacing: 4) {
                    Text(kind == .expense ? "总支出" : "总收入").font(.subheadline).foregroundStyle(.secondary)
                    Text(total.currencyText).font(.title2.bold())
                }
            }
            ForEach(data) { item in
                HStack(spacing: 12) {
                    Image(systemName: item.category.symbol)
                        .foregroundStyle(item.category.color)
                        .frame(width: 34, height: 34)
                        .background(item.category.color.opacity(0.12), in: Circle())
                    Text(item.category.rawValue)
                    Spacer()
                    Text(total > 0 ? (item.amount / total).formatted(.percent.precision(.fractionLength(0))) : "0%")
                        .foregroundStyle(.secondary)
                    Text(item.amount.currencyText).fontWeight(.semibold).frame(width: 90, alignment: .trailing)
                }
            }
        }
    }

    private var budgetPanel: some View {
        let budget = 8_000.0
        let progress = min(store.totalExpense / budget, 1)
        return VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("本月生活预算").font(.headline)
                    Text("已使用 \(store.totalExpense.currencyText)").foregroundStyle(.secondary)
                }
                Spacer()
                Text((budget - store.totalExpense).currencyText).font(.title3.bold())
            }
            ProgressView(value: progress).tint(progress > 0.8 ? .orange : .green).scaleEffect(y: 2)
            HStack { Text("0"); Spacer(); Text("预算 \(budget.currencyText)") }.font(.caption).foregroundStyle(.secondary)
        }
        .padding(18)
        .background(Color(.tertiarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 18))
    }

    private func categoryData(kind: TransactionKind) -> [CategoryAmount] {
        let grouped = Dictionary(grouping: store.transactions.filter { $0.kind == kind }, by: \Transaction.category)
        return grouped.map { CategoryAmount(category: $0.key, amount: $0.value.reduce(0) { $0 + $1.amount }) }
            .sorted { $0.amount > $1.amount }
    }
}

private struct CategoryAmount: Identifiable {
    let category: LedgerCategory
    let amount: Double
    var id: LedgerCategory { category }
}
