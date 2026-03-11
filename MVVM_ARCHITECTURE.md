# MVVM 架构说明

> 本项目实际实现更接近 **MVVM**（Model‑View‑ViewModel），本文档已按现有代码结构与职责重新整理。

##1) 项目结构（与当前仓库一致）

```
SnakeGame/
├── Package.swift
├── Sources/
│ ├── SnakeGame/ #入口目标
│ │ └── main.swift # 应用入口
│ ├── Common/ # 公共模型与配置
│ │ ├── Direction.swift
│ │ ├── Point.swift
│ │ ├── GameState.swift
│ │ ├── GameConfig.swift
│ │ ├── Difficulty.swift
│ │ ├── ColorScheme.swift
│ │ └── SnakeSkin.swift
│ ├── Model/ #纯数据模型
│ │ └── SnakeGameModel.swift
│ ├── Engine/ # 核心游戏引擎
│ │ └── GameEngine.swift
│ ├── Services/ # 数据持久化服务
│ │ └── GameService.swift
│ ├── ViewModel/ #视图模型
│ │ └── SnakeGameViewModel.swift
│ ├── View/ # UI视图
│ │ ├── SnakeGameView.swift
│ │ ├── SnakeRenderer.swift
│ │ ├── SnakeEffects.swift
│ │ └── SkinPreview.swift
│ └── Controller/ # App入口与场景控制
│ └── SnakeGameApp.swift
```

##2) 模块职责

### Common（公共层）
-共享数据结构：`Point / Direction / GameState`
- 配置：`GameConfig / Difficulty`
-主题与皮肤：`ColorScheme / SnakeSkin / SnakeSkinManager`
-视觉特效模型：`SnakeEffectsManager + Effect structs`

### Model（模型层）
- `SnakeGameModel`：仅保存 **游戏状态数据**（蛇身、食物、分数、方向、状态）
- **不包含逻辑**，用于数据承载

### Engine（逻辑引擎层）
- `GameEngine` 协议 + `DefaultGameEngine` 实现
-负责：移动、碰撞检测、计分、生成食物、计时器驱动
-通过回调把分数/碰撞/结束事件反馈给 ViewModel

### Services（服务层）
- `GameService`处理 **持久化**（UserDefaults）
-目前保存：最高分、难度设置

### ViewModel（视图模型层）
- `SnakeGameViewModel`：
 -组合 `Engine + Services + SkinManager`
 -统一管理 `gameState / score / highScore / difficulty / skin`
 - 接收 View 的事件（开始/暂停/方向/难度）并驱动 Engine
 - 对外发布状态供 View 渲染

### View（视图层）
- `SnakeGameView`：组合 UI（标题/分数/难度/皮肤/网格/按钮/说明）
- `SnakeRenderer`：Canvas 绘制蛇和食物
- `SnakeEffects`：粒子、碰撞、分数特效渲染
- `SkinPreview`：皮肤预览组件

### Controller（入口层）
- `SnakeGameApp`：SwiftUI App 启动入口，加载根视图

##3) 数据与事件流（MVVM）

```
用户输入（键盘/按钮）
 → View (SnakeGameView)
 → ViewModel (SnakeGameViewModel)
 → Engine (DefaultGameEngine)
 → 回调（分数/碰撞/结束）
 → ViewModel 发布 @Published 状态
 → View 自动刷新
```

##4) MVVM 的优势（在本项目中体现）
1. **View 无业务逻辑**，只关心展示
2. **ViewModel统一状态**，更容易测试
3. **Engine 可替换**（接口隔离）
4. **Services 可扩展**（可替换持久化实现）

##5)运行方式
```bash
cd /Users/devintan/Desktop/workspace/SnakeGame
swift build
swift run
```

##6)备注
- 原 `MVC_ARCHITECTURE.md` 已改为 MVVM版本，以避免与实际结构不一致。
- 根目录 `SnakeGame.swift` 属于另一套实现（非 Sources体系），建议保留仅作参考或删除避免混淆。
