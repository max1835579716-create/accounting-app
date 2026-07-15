import SwiftUI

struct SavingsView: View {
    let store: AppStore
    @State private var savedAmount = 8_600.0

    var body: some View {
        CollapsingScrollView(isCollapsed: collapseBinding) {
            VStack(spacing: 22) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("攒钱").font(.largeTitle.bold())
                        Text("把想要的生活，一点点存下来").font(.subheadline).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button(action: {}) { Image(systemName: "plus") }.buttonStyle(.bordered)
                }

                SavingsGoalCard(
                    title: "北海道旅行",
                    subtitle: "距离目标还有 128 天",
                    current: savedAmount,
                    target: 20_000,
                    symbol: "airplane.departure",
                    color: .cyan
                ) {
                    withAnimation(.smooth) { savedAmount += 200 }
                }

                SavingsGoalCard(
                    title: "家的小升级",
                    subtitle: "每月自动计划 1,000 元",
                    current: 12_400,
                    target: 30_000,
                    symbol: "sofa",
                    color: .orange,
                    action: {}
                )

                if showsAdditionalDemoGoals {
                    SavingsGoalCard(
                        title: "新电脑计划",
                        subtitle: "为下一台工作设备准备",
                        current: 6_800,
                        target: 18_000,
                        symbol: "laptopcomputer",
                        color: .indigo,
                        action: {}
                    )

                    SavingsGoalCard(
                        title: "周末露营",
                        subtitle: "帐篷和户外装备",
                        current: 2_400,
                        target: 8_000,
                        symbol: "tent",
                        color: .green,
                        action: {}
                    )

                    SavingsGoalCard(
                        title: "年度学习基金",
                        subtitle: "课程、书籍与订阅",
                        current: 3_200,
                        target: 12_000,
                        symbol: "books.vertical",
                        color: .purple,
                        action: {}
                    )

                    SavingsGoalCard(
                        title: "新年礼物",
                        subtitle: "提前准备家人的惊喜",
                        current: 1_600,
                        target: 6_000,
                        symbol: "gift",
                        color: .pink,
                        action: {}
                    )
                }

                VStack(alignment: .leading, spacing: 14) {
                    SectionHeader(title: "小荷包识别", action: "已开启")
                    HStack(spacing: 14) {
                        Image(systemName: "sparkles.rectangle.stack")
                            .font(.title2).foregroundStyle(.indigo)
                            .frame(width: 46, height: 46)
                            .background(.indigo.opacity(0.1), in: Circle())
                        VStack(alignment: .leading, spacing: 4) {
                            Text("识别到“小荷包-旅行”时自动更新")
                                .font(.subheadline.weight(.medium))
                            Text("由你主动触发付款截图识别，不读取支付宝后台")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(16)
                .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 20))
            }
            .padding(18)
            .padding(.bottom, 28)
        }
    }

    private var collapseBinding: Binding<Bool> {
        Binding(get: { store.isTabBarCollapsed }, set: { store.isTabBarCollapsed = $0 })
    }

    private var showsAdditionalDemoGoals: Bool {
        ProcessInfo.processInfo.arguments.contains("--many-savings-goals")
    }
}

private struct SavingsGoalCard: View {
    let title: String
    let subtitle: String
    let current: Double
    let target: Double
    let symbol: String
    let color: Color
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Image(systemName: symbol)
                    .font(.title2).foregroundStyle(color)
                    .frame(width: 50, height: 50)
                    .background(color.opacity(0.12), in: RoundedRectangle(cornerRadius: 15))
                VStack(alignment: .leading, spacing: 4) {
                    Text(title).font(.title3.bold())
                    Text(subtitle).font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                Text((current / target).formatted(.percent.precision(.fractionLength(0)))).font(.headline).foregroundStyle(color)
            }
            ProgressView(value: current, total: target).tint(color).scaleEffect(y: 2)
            HStack {
                Text("\(current.currencyText) / \(target.currencyText)").font(.subheadline.weight(.semibold))
                Spacer()
                Button("存入 200", action: action).buttonStyle(.borderedProminent).buttonBorderShape(.capsule).tint(color)
            }
        }
        .padding(18)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 22))
    }
}
