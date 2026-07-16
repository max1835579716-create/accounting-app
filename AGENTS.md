# Project instructions: visual redesign without structural rewrite

## Primary objective

将现有记账 App 的视觉层改为 `DesignReferences/NewUI` 中展示的温暖、轻量、弗瑞品牌化风格，同时完整保留当前功能、数据、导航和交互语义。

## Non-negotiable boundaries

- 不修改业务规则、金额计算逻辑、日期逻辑、筛选逻辑和数据来源。
- 不修改数据模型、数据库 schema、持久化方式、同步机制、iCloud、导入导出和账户体系。
- 不删除页面、入口、Tab、按钮或原有可操作能力。
- 不改变现有导航目标和返回路径。
- 不改动公开 API、协议、ViewModel 输入输出或外部调用方式，除非先说明原因并获得确认。
- 不引入第三方 UI 依赖，除非先获得确认。
- 不进行与本次视觉改版无关的大规模重构。
- 不使用一张完整效果图作为页面背景来伪装 UI，所有界面必须由原生组件真实构建。
- 不把授设角色当作数据内容。它只能是头像、空状态、页头装饰、卡片角标或轻量反馈插画。

## Required workflow

1. 修改前先阅读并总结当前项目结构、UI 技术栈、导航方式、状态管理、数据流和可复用组件。
2. 先给出变更计划和预计修改文件，不要立即编码。
3. 每次只处理一个页面或一个共享组件层。
4. 修改前后都运行可用的构建、测试和 lint。
5. 每次完成后列出：修改文件、保留项、视觉变化、潜在风险、验证结果。
6. 如果参考图与现有功能冲突，以保留功能为优先，并提出最接近参考图的替代方案。

## Visual system

- 设计参数以 `DESIGN_TOKENS.json` 为准。
- 视觉参考以 `DesignReferences/NewUI` 为准。
- 原页面的信息结构与功能参考以 `DesignReferences/OriginalUI` 为准。
- 授设外观参考以 `DesignReferences/FursonaSources` 为准。
- 使用系统字体和 Dynamic Type，保证中文可读性。
- 保留无障碍标签、按钮点击区域、深浅色兼容策略与 Reduce Motion 支持。
- 装饰图层必须禁止命中测试，并且不能遮挡滚动、点击和 VoiceOver 顺序。

## Architecture preference

优先建立共享设计层，而不是在页面里散落魔法数字：

- AppTheme / DesignTokens
- AppColors
- AppSpacing
- AppRadius
- AppShadow
- AppTypography
- BrandedCard
- BrandedSectionHeader
- BrandedIconTile
- MascotDecoration
- BrandedTabBar / existing tab bar style adapter

保持现有技术栈。若项目是 SwiftUI，就使用 SwiftUI 原生组件；若不是 SwiftUI，先说明技术栈后用对应原生方案实现，不要擅自迁移框架。

## Definition of done

- 功能行为与改版前一致。
- 页面信息没有缺失。
- 新旧版本对比时，仅视觉层、间距、层级、装饰和组件外观发生变化。
- 在目标设备尺寸上无文字截断、重叠、横向溢出或底部导航遮挡。
- 大字体模式、深色模式策略和 VoiceOver 至少经过基本检查。
- 构建成功，现有测试通过。
