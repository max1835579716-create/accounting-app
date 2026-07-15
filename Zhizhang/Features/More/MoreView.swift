import SwiftUI

struct MoreView: View {
    let store: AppStore

    private let sections: [(String, [MoreItem])] = [
        ("日常管理", [
            MoreItem(title: "账户管理", subtitle: "5 个账户", symbol: "creditcard", color: .blue),
            MoreItem(title: "分类管理", subtitle: "按你的习惯整理", symbol: "square.grid.3x3", color: .orange),
            MoreItem(title: "账本管理", subtitle: "日常账本", symbol: "books.vertical", color: .purple),
            MoreItem(title: "预算与周期记账", subtitle: "本月预算正常", symbol: "gauge.with.dots.needle.50percent", color: .green)
        ]),
        ("家庭与数据", [
            MoreItem(title: "家庭管理", subtitle: "默认隐私模式", symbol: "person.2", color: .pink),
            MoreItem(title: "iCloud 备份", subtitle: "原型演示，后续接入", symbol: "icloud", color: .cyan),
            MoreItem(title: "导出 Excel / PDF", subtitle: "选择月份或账本", symbol: "square.and.arrow.up", color: .indigo),
            MoreItem(title: "桌面小组件", subtitle: "小、中、大三种尺寸", symbol: "widget.small", color: .teal)
        ]),
        ("工具", [
            MoreItem(title: "账单搜索", subtitle: "分类、账户、金额", symbol: "magnifyingglass", color: .gray),
            MoreItem(title: "货币 / 汇率", subtitle: "仅作快速换算", symbol: "arrow.left.arrow.right", color: .mint),
            MoreItem(title: "提醒事项", subtitle: "预算、还款、攒钱", symbol: "bell", color: .red),
            MoreItem(title: "设置", subtitle: "知账 1.0", symbol: "gearshape", color: .gray)
        ])
    ]

    var body: some View {
        CollapsingScrollView(isCollapsed: collapseBinding) {
            VStack(spacing: 22) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("更多").font(.largeTitle.bold())
                        Text("账户、家庭与数据工具").font(.subheadline).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 40)).foregroundStyle(.secondary)
                }

                familyBanner

                ForEach(sections, id: \.0) { title, items in
                    VStack(alignment: .leading, spacing: 10) {
                        Text(title).font(.headline).padding(.leading, 4)
                        VStack(spacing: 0) {
                            ForEach(items) { item in
                                Button(action: {}) {
                                    HStack(spacing: 13) {
                                        Image(systemName: item.symbol)
                                            .foregroundStyle(item.color)
                                            .frame(width: 36, height: 36)
                                            .background(item.color.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
                                        VStack(alignment: .leading, spacing: 3) {
                                            Text(item.title).foregroundStyle(.primary).fontWeight(.medium)
                                            Text(item.subtitle).font(.caption).foregroundStyle(.secondary)
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right").font(.caption.bold()).foregroundStyle(.tertiary)
                                    }
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 11)
                                }
                                .buttonStyle(.plain)
                                if item.id != items.last?.id { Divider().padding(.leading, 63) }
                            }
                        }
                        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 18))
                    }
                }
            }
            .padding(18)
            .padding(.bottom, 28)
        }
    }

    private var collapseBinding: Binding<Bool> {
        Binding(get: { store.isTabBarCollapsed }, set: { store.isTabBarCollapsed = $0 })
    }

    private var familyBanner: some View {
        HStack(spacing: 14) {
            Image(systemName: "house.and.flag")
                .font(.title2).foregroundStyle(.pink)
                .frame(width: 48, height: 48)
                .background(.pink.opacity(0.12), in: Circle())
            VStack(alignment: .leading, spacing: 3) {
                Text("建立家庭账户").font(.headline)
                Text("共享汇总，个人明细默认保持隐私").font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Button("创建", action: {}).buttonStyle(.bordered)
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 20))
    }
}

private struct MoreItem: Identifiable {
    let title: String
    let subtitle: String
    let symbol: String
    let color: Color
    var id: String { title }
}
