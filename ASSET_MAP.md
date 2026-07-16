# 素材使用说明

## 现有素材的角色

### `DesignReferences/NewUI`

这些是 Codex 的主要视觉目标。用于判断：

- 页面层级
- 卡片结构
- 颜色比例
- 圆角和间距
- 授设出现的位置与大小
- 底部导航视觉语言

效果图中的文字或图标存在轻微生成偏差时，以当前 App 的真实数据、真实功能和正确中文为准。

### `DesignReferences/OriginalUI`

用于判断哪些页面结构和功能必须保留。Codex 不应因为新效果图没有显示某项内容，就删除原功能。

### `DesignReferences/FursonaSources`

只用于确认授设特征：

- 小熊猫/弗瑞角色
- 橙棕色毛发、白色炸毛刘海
- 左右异瞳：蓝色与琥珀色
- 深棕色爪部
- 可爱、幼态、友好，但不做低龄儿童应用

## 正式开发建议准备的透明 PNG

效果图可以先使用占位资产，但上线前最好额外准备以下透明背景素材：

1. `mascot_avatar.png`：正脸头像，建议 512×512。
2. `mascot_peek_header.png`：双爪趴在卡片边缘，建议 1200×600。
3. `mascot_empty_ledger.png`：趴在账本前的空状态，建议 1200×900。
4. `mascot_savings_travel.png`：旅行/地图动作，建议 1200×900。
5. `mascot_savings_home.png`：家居升级动作，建议 1200×900。
6. `mascot_transaction_happy.png`：开心小贴纸，建议 512×512。
7. `mascot_transaction_worry.png`：担心/出汗小贴纸，建议 512×512。
8. `paw_pattern.png`：可平铺爪印纹理，建议 512×512，低对比度。
9. `tail_corner.png`：页面角落尾巴装饰，建议 800×800。

## 图片接入规则

- 使用 Assets Catalog 管理，不直接写磁盘路径。
- 保留 1x/2x/3x 或使用单张高分辨率 PDF/SVG 矢量图标。
- 插画使用 `.scaledToFit()`，禁止拉伸变形。
- 角色图默认 `accessibilityHidden(true)`，除非它本身承担操作意义。
- 角色图默认 `allowsHitTesting(false)`，避免挡住按钮。
- 卡片角标角色高度建议 48–72pt，页头角色不超过 104pt。
- 如果没有透明素材，先使用 SF Symbols + 爪印装饰完成界面，不要粗暴地把白底图片裁进 App。
