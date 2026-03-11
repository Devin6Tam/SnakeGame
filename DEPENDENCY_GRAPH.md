# SnakeGame — Module & File Dependency Graph

> Generated from local Sources tree (Swift Package). Focuses on *static import/use* relationships and target dependencies.

##1) Target‑level dependency graph (SPM)

```
SnakeGame (executable)
 ├─ Common
 ├─ Model
 ├─ View
 └─ Controller

View
 ├─ Common
 ├─ Model
 └─ ViewModel

ViewModel
 ├─ Model
 ├─ Engine
 └─ Services

Engine
 └─ Common

Services
 └─ Common

Model
 └─ Common
```

##2) File‑level dependency map

### Entry
- `Sources/SnakeGame/main.swift`
 - imports: `Controller`
 - calls: `SnakeGameApp.main()`

### Controller
- `Sources/Controller/SnakeGameApp.swift`
 - imports: `SwiftUI`, `View`
 - creates: `SnakeGameView()`

### ViewModel
- `Sources/ViewModel/SnakeGameViewModel.swift`
 - imports: `Foundation`, `Combine`, `Common`, `Engine`, `Services`
 - owns: `GameEngine`, `GameService`, `SnakeSkinManager`, `SnakeEffectsManager`
 - publishes: `gameState`, `score`, `highScore`, `currentDirection`, `difficulty`, `currentSkin`, `availableSkins`
 - emits: `GameEvent` (Combine)

### Engine
- `Sources/Engine/GameEngine.swift`
 - imports: `Foundation`, `Combine`, `Common`
 - exposes: `GameEngine` protocol
 - implements: `DefaultGameEngine`
 - uses: `GameConfig`, `Point`, `Direction`, `Difficulty`

### Services
- `Sources/Services/GameService.swift`
 - imports: `Foundation`, `Common`
 - exposes: `GameService` protocol
 - implements: `DefaultGameService` (UserDefaults)
 - uses: `Difficulty`

### Model
- `Sources/Model/SnakeGameModel.swift`
 - imports: `Foundation`, `Common`
 - data only: `snake`, `food`, `score`, `currentDirection`, `gameState`
 - uses: `Point`, `Direction`, `GameState`, `GameConfig`

### View
- `Sources/View/SnakeGameView.swift`
 - imports: `SwiftUI`, `AppKit`, `Common`, `Model`, `ViewModel`
 - uses: `SnakeGameViewModel` for all state + actions
 - renders: grid, header, difficulty selector, skin selector, controls, instructions

- `Sources/View/SnakeRenderer.swift`
 - imports: `SwiftUI`, `ViewModel`, `Common`
 - uses: `SnakeGameViewModel` for snake/food/direction/skin
 - renders: snake + food via `Canvas`

- `Sources/View/SnakeEffects.swift`
 - imports: `SwiftUI`, `Common`
 - uses: `SnakeEffectsManager` to render food/collision/score effects

- `Sources/View/SkinPreview.swift`
 - imports: `SwiftUI`, `Common`
 - uses: `SnakeSkin` + `ColorScheme` to render preview tiles

### Common
- `Sources/Common/Direction.swift`
 - defines: `Direction` + `opposite`

- `Sources/Common/Difficulty.swift`
 - defines: `Difficulty` with `moveInterval` and `description`

- `Sources/Common/GameConfig.swift`
 - defines: grid width/height

- `Sources/Common/Point.swift`
 - defines: `Point` (x,y)

- `Sources/Common/GameState.swift`
 - defines: `GameState`

- `Sources/Common/ColorScheme.swift`
 - defines: app UI palette

- `Sources/Common/SnakeSkin.swift`
 - defines: `SnakeSkin`, `SnakeSkinPreset`, `SnakeSkinManager`, `SnakeEffectsManager`, effect models

##3) Runtime flow (high‑level)

```
User Input (keyboard/buttons)
 → View (SnakeGameView)
 → ViewModel (SnakeGameViewModel)
 → Engine (DefaultGameEngine)
 → callbacks (score/gameOver/direction/collision)
 → ViewModel publishes changes
 → View re‑renders
```
