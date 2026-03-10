import SwiftUI

// 游戏方向枚举
enum Direction {
    case up, down, left, right
}

// 游戏状态枚举
enum GameState {
    case notStarted, playing, paused, gameOver
}

// 贪吃蛇游戏模型
class SnakeGame: ObservableObject {
    // 游戏设置
    private let gridSize = 20
    private let gameSpeed: TimeInterval = 0.15
    
    // 游戏状态
    @Published var gameState: GameState = .notStarted
    @Published var score: Int = 0
    @Published var highScore: Int = 0
    
    // 蛇和食物
    @Published var snake: [Point] = []
    @Published var food: Point = Point(x: 0, y: 0)
    @Published var direction: Direction = .right
    
    // 游戏循环
    private var gameTimer: Timer?
    
    // 网格中的点
    struct Point: Hashable {
        let x: Int
        let y: Int
    }
    
    init() {
        resetGame()
        loadHighScore()
    }
    
    // 开始游戏
    func startGame() {
        if gameState == .notStarted || gameState == .gameOver {
            resetGame()
            gameState = .playing
            startGameLoop()
        }
    }
    
    // 暂停游戏
    func pauseGame() {
        if gameState == .playing {
            gameState = .paused
            gameTimer?.invalidate()
        }
    }
    
    // 继续游戏
    func resumeGame() {
        if gameState == .paused {
            gameState = .playing
            startGameLoop()
        }
    }
    
    // 重新开始游戏
    func restartGame() {
        gameState = .notStarted
        resetGame()
    }
    
    // 改变方向
    func changeDirection(_ newDirection: Direction) {
        // 防止直接反向移动
        switch (direction, newDirection) {
        case (.up, .down), (.down, .up), (.left, .right), (.right, .left):
            return
        default:
            direction = newDirection
        }
    }
    
    // 重置游戏
    private func resetGame() {
        score = 0
        snake = [Point(x: 5, y: 10), Point(x: 4, y: 10), Point(x: 3, y: 10)]
        direction = .right
        generateFood()
    }
    
    // 生成食物
    private func generateFood() {
        var newFood: Point
        repeat {
            newFood = Point(x: Int.random(in: 0..<gridSize), 
                           y: Int.random(in: 0..<gridSize))
        } while snake.contains(newFood)
        
        food = newFood
    }
    
    // 开始游戏循环
    private func startGameLoop() {
        gameTimer?.invalidate()
        gameTimer = Timer.scheduledTimer(withTimeInterval: gameSpeed, repeats: true) { [weak self] _ in
            self?.moveSnake()
        }
    }
    
    // 移动蛇
    private func moveSnake() {
        guard gameState == .playing else { return }
        
        var newHead = snake.first!
        
        switch direction {
        case .up:
            newHead = Point(x: newHead.x, y: newHead.y - 1)
        case .down:
            newHead = Point(x: newHead.x, y: newHead.y + 1)
        case .left:
            newHead = Point(x: newHead.x - 1, y: newHead.y)
        case .right:
            newHead = Point(x: newHead.x + 1, y: newHead.y)
        }
        
        // 检查碰撞
        if checkCollision(newHead) {
            gameOver()
            return
        }
        
        // 添加新头部
        snake.insert(newHead, at: 0)
        
        // 检查是否吃到食物
        if newHead == food {
            score += 10
            generateFood()
        } else {
            // 如果没有吃到食物，移除尾部
            snake.removeLast()
        }
    }
    
    // 检查碰撞
    private func checkCollision(_ point: Point) -> Bool {
        // 检查墙壁碰撞
        if point.x < 0 || point.x >= gridSize || point.y < 0 || point.y >= gridSize {
            return true
        }
        
        // 检查自身碰撞
        return snake.contains(point)
    }
    
    // 游戏结束
    private func gameOver() {
        gameState = .gameOver
        gameTimer?.invalidate()
        
        if score > highScore {
            highScore = score
            saveHighScore()
        }
    }
    
    // 加载最高分
    private func loadHighScore() {
        highScore = UserDefaults.standard.integer(forKey: "SnakeGameHighScore")
    }
    
    // 保存最高分
    private func saveHighScore() {
        UserDefaults.standard.set(highScore, forKey: "SnakeGameHighScore")
    }
}

// 游戏主视图
struct SnakeGameView: View {
    @StateObject private var game = SnakeGame()
    
    var body: some View {
        VStack(spacing: 20) {
            // 标题和分数
            HStack {
                Text("贪吃蛇游戏")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("分数: \(game.score)")
                        .font(.title2)
                    Text("最高分: \(game.highScore)")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
            
            // 游戏区域
            ZStack {
                // 网格背景
                GridBackground(gridSize: game.gridSize)
                
                // 蛇
                ForEach(Array(game.snake.enumerated()), id: \.offset) { index, point in
                    SnakeSegment(point: point, gridSize: game.gridSize, isHead: index == 0)
                }
                
                // 食物
                FoodView(point: game.food, gridSize: game.gridSize)
            }
            .frame(width: 400, height: 400)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            // 控制按钮
            VStack(spacing: 12) {
                // 方向控制
                HStack(spacing: 20) {
                    DirectionButton(direction: .up, action: { game.changeDirection(.up) })
                }
                
                HStack(spacing: 20) {
                    DirectionButton(direction: .left, action: { game.changeDirection(.left) })
                    Spacer()
                        .frame(width: 60)
                    DirectionButton(direction: .right, action: { game.changeDirection(.right) })
                }
                
                HStack(spacing: 20) {
                    DirectionButton(direction: .down, action: { game.changeDirection(.down) })
                }
                
                // 游戏控制按钮
                HStack(spacing: 20) {
                    if game.gameState == .notStarted || game.gameState == .gameOver {
                        GameButton(title: "开始游戏", color: .green, action: { game.startGame() })
                    } else if game.gameState == .playing {
                        GameButton(title: "暂停", color: .orange, action: { game.pauseGame() })
                    } else if game.gameState == .paused {
                        GameButton(title: "继续", color: .blue, action: { game.resumeGame() })
                    }
                    
                    GameButton(title: "重新开始", color: .red, action: { game.restartGame() })
                }
                .padding(.top, 10)
            }
            .padding(.horizontal, 40)
            
            // 游戏状态提示
            Text(gameStateText)
                .font(.title3)
                .foregroundColor(gameStateColor)
                .padding()
        }
        .padding()
        .background(Color(.systemBackground))
        .focusable()
        .onKeyPress { press in
            handleKeyPress(press)
            return .handled
        }
    }
    
    // 游戏状态文本
    private var gameStateText: String {
        switch game.gameState {
        case .notStarted:
            return "点击开始游戏"
        case .playing:
            return "游戏进行中..."
        case .paused:
            return "游戏已暂停"
        case .gameOver:
            return "游戏结束！最终得分: \(game.score)"
        }
    }
    
    // 游戏状态颜色
    private var gameStateColor: Color {
        switch game.gameState {
        case .notStarted:
            return .blue
        case .playing:
            return .green
        case .paused:
            return .orange
        case .gameOver:
            return .red
        }
    }
    
    // 键盘事件处理
    private func handleKeyPress(_ press: KeyPress) {
        guard game.gameState == .playing || game.gameState == .paused else { return }
        
        switch press.key {
        case .upArrow:
            game.changeDirection(.up)
        case .downArrow:
            game.changeDirection(.down)
        case .leftArrow:
            game.changeDirection(.left)
        case .rightArrow:
            game.changeDirection(.right)
        case .space:
            if game.gameState == .playing {
                game.pauseGame()
            } else if game.gameState == .paused {
                game.resumeGame()
            }
        case .return:
            if game.gameState == .notStarted || game.gameState == .gameOver {
                game.startGame()
            }
        default:
            break
        }
    }
}

// 网格背景视图
struct GridBackground: View {
    let gridSize: Int
    
    var body: some View {
        GeometryReader { geometry in
            let cellSize = min(geometry.size.width, geometry.size.height) / CGFloat(gridSize)
            
            Path { path in
                // 绘制垂直线
                for i in 0...gridSize {
                    let x = CGFloat(i) * cellSize
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: geometry.size.height))
                }
                
                // 绘制水平线
                for i in 0...gridSize {
                    let y = CGFloat(i) * cellSize
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                }
            }
            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        }
    }
}

// 蛇身段视图
struct SnakeSegment: View {
    let point: SnakeGame.Point
    let gridSize: Int
    let isHead: Bool
    
    var body: some View {
        GeometryReader { geometry in
            let cellSize = min(geometry.size.width, geometry.size.height) / CGFloat(gridSize)
            let x = CGFloat(point.x) * cellSize + cellSize / 2
            let y = CGFloat(point.y) * cellSize + cellSize / 2
            
            Circle()
                .fill(isHead ? Color.green : Color.green.opacity(0.7))
                .frame(width: cellSize - 4, height: cellSize - 4)
                .position(x: x, y: y)
                .shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 1)
        }
    }
}

// 食物视图
struct FoodView: View {
    let point: SnakeGame.Point
    let gridSize: Int
    
    var body: some View {
        GeometryReader { geometry in
            let cellSize = min(geometry.size.width, geometry.size.height) / CGFloat(gridSize)
            let x = CGFloat(point.x) * cellSize + cellSize / 2
            let y = CGFloat(point.y) * cellSize + cellSize / 2
            
            Circle()
                .fill(Color.red)
                .frame(width: cellSize - 6, height: cellSize - 6)
                .position(x: x, y: y)
                .shadow(color: .red.opacity(0.5), radius: 4, x: 0, y: 0)
        }
    }
}

// 方向按钮
struct DirectionButton: View {
    let direction: Direction
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: directionIconName)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(Color.blue)
                .cornerRadius(10)
                .shadow(color: .black.opacity(0.2), radius: 3, x: 2, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var directionIconName: String {
        switch direction {
        case .up: return "arrow.up"
        case .down: return "arrow.down"
        case .left: return "arrow.left"
        case .right: return "arrow.right"
        }
    }
}

// 游戏控制按钮
struct GameButton: View {
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(color)
                .cornerRadius(8)
                .shadow(color: .black.opacity(0.2), radius: 3, x: 2, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// 应用入口
@main
struct SnakeGameApp: App {
    var body: some Scene {
        WindowGroup {
            SnakeGameView()
                .frame(minWidth: 600, minHeight: 800)
        }
    }
}