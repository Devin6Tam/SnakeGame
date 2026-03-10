# MVC 架构说明

## 项目结构

本项目采用 MVC（Model-View-Controller）架构模式，将代码组织成多个独立的模块。

## 目录结构

```
SnakeGame/
├── Package.swift                      # Swift Package Manager 配置文件
├── Sources/
│   ├── SnakeGame/                     # 主可执行目标
│   │   └── main.swift                 # 应用入口点
│   ├── Common/                        # 公共模块
│   │   ├── Direction.swift            # 方向枚举
│   │   ├── Point.swift                # 点结构
│   │   ├── GameState.swift            # 游戏状态枚举
│   │   ├── GameConfig.swift           # 游戏配置常量
│   │   ├── Difficulty.swift           # 难度等级
│   │   └── ColorScheme.swift          # 配色方案
│   ├── Model/                         # 模型层
│   │   └── SnakeGameModel.swift       # 游戏逻辑和数据模型
│   ├── View/                          # 视图层
│   │   └── SnakeGameView.swift        # UI 组件和视图
│   └── Controller/                    # 控制器层
│       └── SnakeGameApp.swift         # 应用入口控制器
```

## 模块说明

### 1. Common（公共模块）
**职责**：提供共享的数据结构和常量

**包含文件**：
- `Direction.swift`：游戏方向枚举（上、下、左、右）
- `Point.swift`：表示网格上的点的结构
- `GameState.swift`：游戏状态枚举（游戏中、暂停、结束、未开始）
- `GameConfig.swift`：游戏配置常量（网格大小）
- `Difficulty.swift`：难度等级（简单、中等、困难、专家）
- `ColorScheme.swift`：配色方案（莫兰迪色系）

**依赖关系**：无

### 2. Model（模型层）
**职责**：处理游戏逻辑和数据管理

**包含文件**：
- `SnakeGameModel.swift`：游戏的核心逻辑类，继承自 `ObservableObject`

**主要功能**：
- 游戏状态管理（分数、最高分、游戏状态、难度等级）
- 蛇的移动逻辑（根据难度调整速度）
- 碰撞检测
- 食物生成
- 数据持久化（最高分、难度设置保存）
- 游戏控制方法（开始、暂停、继续、重启、设置难度）

**依赖关系**：Common

### 3. View（视图层）
**职责**：负责 UI 渲染和用户界面

**包含文件**：
- `SnakeGameView.swift`：主游戏视图

**主要功能**：
- 游戏网格渲染（柔和配色）
- 蛇和食物的绘制（莫兰迪色系）
- 难度选择器
- 控制按钮显示（带阴影效果）
- 键盘事件处理
- 分数和状态显示

**设计特点**：
- 采用莫兰迪色系，整体色彩柔和舒适
- 按钮带阴影效果，增强立体感
- 圆角设计，视觉更加柔和

**依赖关系**：Common, Model

### 4. Controller（控制器层）
**职责**：协调 Model 和 View，管理应用生命周期

**包含文件**：
- `SnakeGameApp.swift`：应用主入口

**主要功能**：
- 定义应用的主场景
- 初始化根视图

**依赖关系**：View

### 5. SnakeGame（主可执行目标）
**职责**：应用的入口点

**包含文件**：
- `main.swift`：调用应用入口的 main 函数

**依赖关系**：Common, Model, View, Controller

## 新增功能

### 难度等级系统
- **简单**：移动间隔 0.4 秒，适合休闲玩家
- **中等**：移动间隔 0.25 秒，适合新手
- **困难**：移动间隔 0.15 秒，挑战自我
- **专家**：移动间隔 0.1 秒，极限挑战

难度设置会自动保存，下次启动时恢复。

### 柔和配色方案（莫兰迪色系）
- 蛇头：柔和的薄荷绿
- 蛇身：柔和的灰绿
- 食物：柔和的珊瑚粉
- 网格背景：浅灰
- 应用背景：米白
- 按钮：柔和的蓝色、绿色、黄色、橙色

所有颜色都经过精心调配，确保视觉舒适，长时间游玩不疲劳。

## 依赖关系图

```
SnakeGame (入口)
    ↓
Controller
    ↓
View
    ↓
Model
    ↓
Common
```

## MVC 架构优势

1. **分离关注点**：
   - Model 专注于游戏逻辑
   - View 专注于 UI 渲染
   - Controller 专注于协调

2. **可测试性**：每个模块可以独立测试

3. **可维护性**：代码组织清晰，易于理解和修改

4. **可重用性**：公共模块可以在其他项目中重用

5. **模块化**：每个模块都有明确的职责和依赖关系

## 构建和运行

### 构建项目
```bash
cd /Users/devintan/Desktop/workspace/SnakeGame
swift build
```

### 运行项目
```bash
cd /Users/devintan/Desktop/workspace/SnakeGame
swift run
```

### 在 Xcode 中打开
直接用 Xcode 打开 `Package.swift` 文件即可
