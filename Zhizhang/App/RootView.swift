import SwiftUI

private enum EntryDestination: String, Identifiable {
    case add

    var id: String { rawValue }
}

struct RootView: View {
    @State private var store = AppStore.demo

    var body: some View {
        CustomTabShell(store: store)
        .environment(store)
        .tint(AppTheme.Colors.accentOrange)
        .preferredColorScheme(.light)
    }
}

private struct CustomTabShell: View {
    @Bindable var store: AppStore
    @State private var destination: EntryDestination?

    init(store: AppStore) {
        self.store = store
        _destination = State(
            initialValue: ProcessInfo.processInfo.arguments.contains("--show-entry")
                ? .add
                : nil
        )
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            AppTheme.Gradients.warmSurface.ignoresSafeArea()

            TabContent(
                tab: store.selectedTab,
                store: store,
                onAddTransaction: presentQuickEntry
            )
                .safeAreaPadding(.bottom, 76)

            FloatingTabBar(
                selection: $store.selectedTab,
                isCollapsed: $store.isTabBarCollapsed,
                onReselect: handleTabReselection
            )
            .padding(.bottom, 4)
        }
        .sheet(item: $destination) { _ in
            AddTransactionSheet(store: store, initialDate: store.selectedDate)
                .presentationDetents([.fraction(0.78), .large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(32)
        }
    }

    private func handleTabReselection(_ tab: AppTab) {
        guard tab == .calendar else { return }
        presentQuickEntry()
    }

    private func presentQuickEntry() {
        guard destination == nil else { return }
        destination = .add
    }
}

private struct TabContent: View {
    let tab: AppTab
    let store: AppStore
    let onAddTransaction: () -> Void

    @ViewBuilder
    var body: some View {
        switch tab {
        case .analysis:
            AnalysisView(store: store)
        case .bills:
            BillsView(store: store)
        case .calendar:
            CalendarLedgerView(
                store: store,
                onAddTransaction: onAddTransaction
            )
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
