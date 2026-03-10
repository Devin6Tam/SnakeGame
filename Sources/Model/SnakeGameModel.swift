import Foundation
import Combine
import Common

/// 贪吃蛇游戏模型（Model层）
public class SnakeGameModel: ObservableObject {
    // MARK: - 发布属性
    
    /// 蛇身
    @Published public private(set) var snake: [Point] = []
    
    /// 食物位置
    @Published public private(set) var food: Point?
    
    /// 当前分数
    @Published public private(set) var score = 0
    
    /// 最高分
    @Published public private(set) var highScore = 0
    
    /// 游戏状态
    @Published public private(set) var gameState: GameState = .notStarted
    
    /// 当前移动方向
    @Published public private(set) var currentDirection: Direction = .right
    
    /// 下次移动方向（用于防止快速按键导致的冲突）
    public private(set) var nextDirection: Direction = .right
    
    /// 难度等级
    @Published public var difficulty: Difficulty = .medium
    
    // MARK: - 私有属性
    
    /// 游戏计时器
    private var gameTimer: Timer?
    
    /// UserDefaults的key
    private let highScoreKey = "snakeHighScore"
    
    // MARK: - 初始化
    
    public init() {
        loadHighScore()
        loadDifficulty()
    }
    
    // MARK: - 游戏控制方法
    
    /// 开始游戏
    public func startGame() {
        resetGame()
        gameState = .playing
        startGameTimer()
    }
    
    /// 暂停游戏
    public func pauseGame() {
        if gameState == .playing {
            gameState = .paused
            stopGameTimer()
        }
    }
    
    /// 继续游戏
    public func resumeGame() {
        if gameState == .paused {
            gameState = .playing
            startGameTimer()
        }
    }
    
    /// 重新开始游戏
    public func restartGame() {
        startGame()
    }
    
    /// 改变蛇的移动方向
    public func changeDirection(_ direction: Direction) {
        // 防止直接反向移动
        if direction != currentDirection.opposite {
            nextDirection = direction
        }
    }
    
    /// 设置难度等级
    public func setDifficulty(_ difficulty: Difficulty) {
        self.difficulty = difficulty
        saveDifficulty()
        
        // 如果游戏正在运行，需要重启计时器以应用新的速度
        if gameState == .playing {
            startGameTimer()
        }
    }
    
    // MARK: - 游戏逻辑（私有方法）
    
    /// 重置游戏
    private func resetGame() {
        snake = [
            Point(x: GameConfig.gridWidth / 2, y: GameConfig.gridHeight / 2),
            Point(x: GameConfig.gridWidth / 2 - 1, y: GameConfig.gridHeight / 2),
            Point(x: GameConfig.gridWidth / 2 - 2, y: GameConfig.gridHeight / 2)
        ]
        currentDirection = .right
        nextDirection = .right
        score = 0
        generateFood()
    }
    
    /// 生成食物
    private func generateFood() {
        var availablePoints: Set<Point> = []
        
        // 生成所有可能的点，排除蛇身占据的点
        for x in 0..<GameConfig.gridWidth {
            for y in 0..<GameConfig.gridHeight {
                let point = Point(x: x, y: y)
                if !snake.contains(point) {
                    availablePoints.insert(point)
                }
            }
        }
        
        // 随机选择一个点作为食物
        if let randomPoint = availablePoints.randomElement() {
            food = randomPoint
        } else {
            // 如果没有可用点（蛇占满了整个网格），游戏获胜
            food = nil
        }
    }
    
    /// 移动蛇
    private func moveSnake() {
        guard gameState == .playing else { return }
        
        // 更新方向
        currentDirection = nextDirection
        
        // 计算新的头部位置
        let head = snake.first!
        var newHead: Point
        
        switch currentDirection {
        case .up:
            newHead = Point(x: head.x, y: head.y - 1)
        case .down:
            newHead = Point(x: head.x, y: head.y + 1)
        case .left:
            newHead = Point(x: head.x - 1, y: head.y)
        case .right:
            newHead = Point(x: head.x + 1, y: head.y)
        }
        
        // 检查碰撞
        if checkCollision(at: newHead) {
            gameOver()
            return
        }
        
        // 移动蛇
        snake.insert(newHead, at: 0)
        
        // 检查是否吃到食物
        if let foodPoint = food, newHead == foodPoint {
            // 吃到食物，增加分数，生成新食物
            score += 10
            generateFood()
            
            // 更新最高分
            if score > highScore {
                highScore = score
                saveHighScore()
            }
        } else {
            // 没有吃到食物，移除尾部
            snake.removeLast()
        }
    }
    
    /// 检查碰撞
    private func checkCollision(at point: Point) -> Bool {
        // 检查墙壁碰撞
        if point.x < 0 || point.x >= GameConfig.gridWidth || 
           point.y < 0 || point.y >= GameConfig.gridHeight {
            return true
        }
        
        // 检查自身碰撞（跳过头部本身）
        for (index, snakePoint) in snake.enumerated() {
            if index != 0 && point == snakePoint {
                return true
            }
        }
        
        return false
    }
    
    /// 游戏结束
    private func gameOver() {
        gameState = .gameOver
        stopGameTimer()
    }
    
    // MARK: - 计时器管理
    
    /// 启动游戏计时器
    private func startGameTimer() {
        stopGameTimer()
        gameTimer = Timer.scheduledTimer(
            withTimeInterval: difficulty.moveInterval,
            repeats: true
        ) { [weak self] _ in
            self?.moveSnake()
        }
    }
    
    /// 停止游戏计时器
    private func stopGameTimer() {
        gameTimer?.invalidate()
        gameTimer = nil
    }
    
    // MARK: - 数据持久化
    
    /// 保存最高分
    private func saveHighScore() {
        UserDefaults.standard.set(highScore, forKey: highScoreKey)
    }
    
    /// 加载最高分
    private func loadHighScore() {
        highScore = UserDefaults.standard.integer(forKey: highScoreKey)
    }
    
    /// 保存难度等级
    private func saveDifficulty() {
        UserDefaults.standard.set(difficulty.rawValue, forKey: "snakeDifficulty")
    }
    
    /// 加载难度等级
    private func loadDifficulty() {
        if let difficultyString = UserDefaults.standard.string(forKey: "snakeDifficulty"),
           let savedDifficulty = Difficulty(rawValue: difficultyString) {
            difficulty = savedDifficulty
        }
    }
    
    // MARK: - 辅助方法
    
    /// 判断指定位置是否是蛇头
    public func isSnakeHead(at point: Point) -> Bool {
        return snake.first == point
    }
    
    /// 判断指定位置是否是蛇身
    public func isSnakeBody(at point: Point) -> Bool {
        return snake.contains(point) && snake.first != point
    }
    
    /// 判断指定位置是否有食物
    public func isFood(at point: Point) -> Bool {
        return food == point
    }
    
    deinit {
        stopGameTimer()
    }
}
