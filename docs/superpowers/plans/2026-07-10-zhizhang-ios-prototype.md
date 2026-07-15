# 知账 iOS 可运行原型 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 创建一个最低支持 iOS 17、可在 iOS 26.5 模拟器运行的知账 1.0 SwiftUI 前端原型，覆盖五栏导航、分析、账单、日历记账、攒钱和设置主流程。

**Architecture:** 使用一个根级 `@Observable AppStore` 保存演示账单、当前标签和新增账单状态；各功能页面作为小型 SwiftUI View 读取同一数据源。自定义悬浮导航统一处理选中状态和滚动收缩，新增账单通过 item-driven sheet 呈现。iOS 26 使用原生 Liquid Glass，iOS 17-18 使用系统 Material 降级。

**Tech Stack:** Swift 6、SwiftUI、Charts、Observation、XCTest、Xcode 26.6；不引入第三方依赖。

## Global Constraints

- App 名称为“知账”，版本为 1.0。
- `IPHONEOS_DEPLOYMENT_TARGET = 17.0`。
- 导航固定五个纯图标位置：明细、账单、加号、攒钱、更多，导航内无文字。
- 中间加号未选中时与其他图标同等视觉权重。
- 最新系统使用原生 Liquid Glass，低版本使用系统材质。
- 本轮目标是可运行前端和本地演示数据；iCloud、家庭实时同步、App Intents、WidgetKit、OCR、Excel/PDF 实际导出在后续里程碑实现。

---

### Task 1: 工程骨架与可测试模型

**Files:**
- Create: `Zhizhang.xcodeproj/project.pbxproj`
- Create: `Zhizhang/App/ZhizhangApp.swift`
- Create: `Zhizhang/Model/LedgerModels.swift`
- Create: `Zhizhang/Model/AppStore.swift`
- Create: `ZhizhangTests/AppStoreTests.swift`

**Interfaces:**
- Produces: `Transaction`, `TransactionKind`, `LedgerCategory`, `AppStore`, `AppTab`。

- [ ] 写 `AppStoreTests`，验证默认数据汇总与新增支出后余额、日历数据更新。
- [ ] 运行 `xcodebuild test`，确认测试因模型缺失而失败。
- [ ] 实现最小模型与 `AppStore.addTransaction(...)`。
- [ ] 运行测试，确认通过。

### Task 2: App 外壳和液态玻璃导航

**Files:**
- Create: `Zhizhang/App/RootView.swift`
- Create: `Zhizhang/Components/GlassSurface.swift`
- Create: `Zhizhang/Components/FloatingTabBar.swift`

**Interfaces:**
- Consumes: `AppStore`, `AppTab`。
- Produces: `RootView` 与可展开/收缩的 `FloatingTabBar`。

- [ ] 为每个导航项添加稳定 accessibility identifier。
- [ ] 实现五图标等权布局、当前项内嵌高亮、向下滚动收缩为当前图标圆球、向上恢复。
- [ ] iOS 26 分支使用 `GlassEffectContainer` 与 `glassEffect`，iOS 17 降级为 `ultraThinMaterial`。
- [ ] 编译工程，确认所有可用性分支通过。

### Task 3: 明细分析与账单页

**Files:**
- Create: `Zhizhang/Features/Analysis/AnalysisView.swift`
- Create: `Zhizhang/Features/Analysis/TrendChartView.swift`
- Create: `Zhizhang/Features/Bills/BillsView.swift`

**Interfaces:**
- Consumes: `AppStore.transactions` 及其汇总属性。
- Produces: 个人/家庭切换、五种分析切换、收支/资产趋势图、账单列表。

- [ ] 实现顶部个人/家庭、月份和分析类型控制。
- [ ] 用 Swift Charts 绘制收支趋势及资产趋势，并保持指标胶囊、网格图、汇总表结构一致。
- [ ] 实现账单月度汇总、搜索按钮、筛选按钮和按日分组列表。
- [ ] 编译并在预览尺寸检查文字不截断。

### Task 4: 日历记账与底部输入面板

**Files:**
- Create: `Zhizhang/Features/Calendar/CalendarLedgerView.swift`
- Create: `Zhizhang/Features/Calendar/MonthCalendarView.swift`
- Create: `Zhizhang/Features/Entry/AddTransactionSheet.swift`
- Create: `Zhizhang/Components/AmountKeypad.swift`

**Interfaces:**
- Consumes: `AppStore.transactions`, `AppStore.addTransaction(...)`。
- Produces: 月历、选中日明细、分类网格、金额键盘、保存后刷新。

- [ ] 实现七列月历，日期格显示当日收入/支出摘要。
- [ ] 实现小票、资产、清单、预算快捷入口和日期账单列表。
- [ ] 从页面新增动作弹出非全屏底部 sheet，支持支出/收入、分类、账户、日期、备注和数字键盘。
- [ ] 保存后调用 `AppStore.addTransaction(...)` 并 dismiss，验证日历明细立即更新。

### Task 5: 攒钱、更多与模拟器验收

**Files:**
- Create: `Zhizhang/Features/Savings/SavingsView.swift`
- Create: `Zhizhang/Features/More/MoreView.swift`
- Create: `Zhizhang/Assets.xcassets/Contents.json`
- Create: `Zhizhang/Assets.xcassets/AccentColor.colorset/Contents.json`
- Create: `Zhizhang/Assets.xcassets/AppIcon.appiconset/Contents.json`

**Interfaces:**
- Consumes: 根导航和演示状态。
- Produces: 攒钱目标界面、设置入口、可安装 App 包。

- [ ] 实现目标进度、手动存入入口和小荷包识别说明状态。
- [ ] 实现账户、分类、账本、预算、家庭、汇率、备份、导出、小组件和设置入口。
- [ ] 运行完整 XCTest 与 Debug 构建。
- [ ] 启动 iPhone 17 Pro 模拟器，安装并打开 App。
- [ ] 截图并检查五栏导航、日历、底部记账 sheet 与趋势图；修复阻塞性视觉或交互问题。

