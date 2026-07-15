import SwiftUI

struct RootView: View {
    @State private var store = AppStore.demo

    var body: some View {
        CustomTabShell(store: store)
        .environment(store)
        .tint(Color(red: 0.88, green: 0.20, blue: 0.32))
        .preferredColorScheme(.light)
    }
}

private struct CustomTabShell: View {
    @Bindable var store: AppStore

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(.systemGroupedBackground).ignoresSafeArea()

            TabContent(tab: store.selectedTab, store: store)
                .safeAreaPadding(.bottom, 76)

            FloatingTabBar(
                selection: $store.selectedTab,
                isCollapsed: $store.isTabBarCollapsed
            )
            .padding(.bottom, 4)
        }
    }
}

private struct TabContent: View {
    let tab: AppTab
    let store: AppStore

    @ViewBuilder
    var body: some View {
        switch tab {
        case .analysis:
            AnalysisView(store: store)
        case .bills:
            BillsView(store: store)
        case .calendar:
            CalendarLedgerView(store: store)
        case .savings:
            SavingsView(store: store)
        case .more:
            MoreView(store: store)
        }
    }
}

#Preview {
    RootView()
}
