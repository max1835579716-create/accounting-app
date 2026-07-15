import Charts
import SwiftUI

enum TrendKind {
    case cashflow
    case assets
}

struct TrendChartView: View {
    let store: AppStore
    let kind: TrendKind

    private var summaries: [DailySummary] { store.dailySummaries }

    var body: some View {
        VStack(spacing: 18) {
            metrics
            chart
                .frame(height: 260)
            table
        }
    }

    private var metrics: some View {
        HStack(spacing: 8) {
            if kind == .cashflow {
                MetricPill(title: "日均收入", value: averageIncome.currencyText, color: .green)
                MetricPill(title: "日均支出", value: averageExpense.currencyText, color: .red)
                MetricPill(title: "本月结余", value: store.balance.currencyText, color: .indigo)
            } else {
                MetricPill(title: "当前资产", value: currentAssets.currencyText, color: .green)
                MetricPill(title: "本月变化", value: store.balance.currencyText, color: store.balance >= 0 ? .green : .red)
                MetricPill(title: "账户数", value: "5", color: .indigo)
            }
        }
    }

    @ViewBuilder
    private var chart: some View {
        if kind == .cashflow {
            Chart(summaries) { item in
                LineMark(x: .value("日期", item.date), y: .value("收入", item.income))
                    .foregroundStyle(.green)
                    .lineStyle(.init(lineWidth: 3, lineCap: .round, lineJoin: .round))
                PointMark(x: .value("日期", item.date), y: .value("收入", item.income))
                    .foregroundStyle(.green)
                LineMark(x: .value("日期", item.date), y: .value("支出", item.expense))
                    .foregroundStyle(.red.opacity(0.78))
                    .lineStyle(.init(lineWidth: 3, lineCap: .round, lineJoin: .round))
                PointMark(x: .value("日期", item.date), y: .value("支出", item.expense))
                    .foregroundStyle(.red.opacity(0.78))
            }
            .chartXAxis { AxisMarks(values: .automatic(desiredCount: 5)) { AxisGridLine(); AxisValueLabel(format: .dateTime.day()) } }
            .chartYAxis { AxisMarks(position: .leading) { AxisGridLine(); AxisValueLabel() } }
            .chartLegend(.hidden)
        } else {
            Chart(assetPoints) { item in
                AreaMark(x: .value("日期", item.date), y: .value("资产", item.value))
                    .foregroundStyle(.linearGradient(colors: [.green.opacity(0.28), .green.opacity(0.02)], startPoint: .top, endPoint: .bottom))
                LineMark(x: .value("日期", item.date), y: .value("资产", item.value))
                    .foregroundStyle(.green)
                    .lineStyle(.init(lineWidth: 3.5, lineCap: .round, lineJoin: .round))
                PointMark(x: .value("日期", item.date), y: .value("资产", item.value))
                    .foregroundStyle(.green)
            }
            .chartXAxis { AxisMarks(values: .automatic(desiredCount: 5)) { AxisGridLine(); AxisValueLabel(format: .dateTime.day()) } }
            .chartYAxis { AxisMarks(position: .leading) { AxisGridLine(); AxisValueLabel() } }
        }
    }

    private var table: some View {
        VStack(spacing: 0) {
            HStack {
                Text("日期")
                Spacer()
                Text(kind == .cashflow ? "收入" : "资产")
                Spacer()
                Text(kind == .cashflow ? "支出" : "变化")
                Spacer()
                Text(kind == .cashflow ? "总额" : "余额")
            }
            .font(.caption.weight(.medium))
            .foregroundStyle(.secondary)
            .padding(.bottom, 10)

            if kind == .cashflow {
                TrendTableRow(label: "总额", first: store.totalIncome, second: store.totalExpense, total: store.balance)
                ForEach(summaries.suffix(4).reversed()) { item in
                    TrendTableRow(label: item.date.formatted(.dateTime.day().month()), first: item.income, second: item.expense, total: item.balance)
                }
            } else {
                TrendTableRow(label: "当前", first: currentAssets, second: store.balance, total: currentAssets)
                ForEach(assetPoints.suffix(4).reversed()) { item in
                    TrendTableRow(label: item.date.formatted(.dateTime.day().month()), first: item.value, second: item.change, total: item.value)
                }
            }
        }
    }

    private var averageIncome: Double { store.totalIncome / max(Double(summaries.count), 1) }
    private var averageExpense: Double { store.totalExpense / max(Double(summaries.count), 1) }
    private var currentAssets: Double { 80_000 + store.balance }

    private var assetPoints: [AssetPoint] {
        var value = 80_000.0
        return summaries.map {
            value += $0.balance
            return AssetPoint(date: $0.date, value: value, change: $0.balance)
        }
    }
}

private struct AssetPoint: Identifiable {
    let date: Date
    let value: Double
    let change: Double
    var id: Date { date }
}

private struct MetricPill: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title).font(.caption2).foregroundStyle(.secondary)
            Text(value).font(.caption.weight(.semibold)).foregroundStyle(color).lineLimit(1).minimumScaleFactor(0.72)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 10)
        .padding(.vertical, 9)
        .background(color.opacity(0.08), in: Capsule())
        .overlay { Capsule().stroke(color.opacity(0.18), lineWidth: 0.8) }
    }
}

private struct TrendTableRow: View {
    let label: String
    let first: Double
    let second: Double
    let total: Double

    var body: some View {
        HStack {
            Text(label).frame(maxWidth: .infinity, alignment: .leading)
            Text(first.currencyText).foregroundStyle(.green).lineLimit(1).minimumScaleFactor(0.55).frame(maxWidth: .infinity, alignment: .trailing)
            Text(second.currencyText).foregroundStyle(.red).lineLimit(1).minimumScaleFactor(0.55).frame(maxWidth: .infinity, alignment: .trailing)
            Text(total.currencyText).foregroundStyle(total >= 0 ? Color.primary : Color.red).fontWeight(.semibold).lineLimit(1).minimumScaleFactor(0.55).frame(maxWidth: .infinity, alignment: .trailing)
        }
        .font(.caption)
        .padding(.vertical, 8)
        .overlay(alignment: .bottom) { Divider().opacity(0.45) }
    }
}
