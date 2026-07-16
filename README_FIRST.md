# Codex 改版素材包使用说明

这个素材包的目标是：**保留现有 App 的功能、数据结构、导航关系和页面主体信息架构，只替换视觉层与少量展示组件**。

## 推荐执行顺序

1. 先把当前项目提交一次 Git：`git add . && git commit -m "before furry UI redesign"`
2. 把本素材包中的 `AGENTS.md` 放到项目仓库根目录。
3. 把 `DesignReferences` 整个文件夹复制到项目根目录，路径保持不变。
4. 将 `CODEX_UI_REDESIGN_TASK.md` 的“第一阶段提示词”发给 Codex。此阶段只让它检查项目，不允许改代码。
5. Codex 输出审计结果后，再发送“第二阶段提示词”，先建立设计系统和共享组件。
6. 按照 账单 → 日常账本 → 攒钱 → 明细 → 更多 的顺序逐页改，避免一次性把全项目搅成奶昔。
7. 每完成一页，要求 Codex 运行项目、截图、对照参考图检查，并说明改了哪些文件。

## 最重要的原则

- 不改业务逻辑。
- 不改数据模型。
- 不改持久化、登录、iCloud、导出等功能实现。
- 不重写导航结构。
- 不为了“看起来更干净”而删除现有功能。
- 新增视觉组件时优先复用，避免每个页面各写一套。
- 角色图片只作为品牌装饰，不遮挡数据，不降低可读性。

## 文件说明

- `AGENTS.md`：项目级长期规则，Codex 每次工作都应遵守。
- `CODEX_UI_REDESIGN_TASK.md`：可以直接复制给 Codex 的分阶段提示词。
- `DESIGN_TOKENS.json`：颜色、圆角、间距、阴影、字号等设计参数。
- `ASSET_MAP.md`：素材如何使用，以及正式开发还需要准备的透明 PNG。
- `SCREEN_CHECKLIST.md`：逐页验收清单。
- `DesignReferences/NewUI`：本次喜欢的新界面效果图。
- `DesignReferences/OriginalUI`：目前 App 原始界面，用于判断哪些内容必须保留。
- `DesignReferences/FursonaSources`：授设外观参考，不代表可以直接裁切进 App。
