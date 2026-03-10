import Foundation
import Combine
import Common

/// 游戏引擎协议
public protocol GameEngine {
    /// 蛇身位置
    var snake: [Point] { get }
    
    /// 食物位置
    var food: Point? { get }
    
    /// 当前分数
    var score: Int { get }
    
    /// 游戏状态回调
    var onScoreUpdate: ((Int) -> Void)? { get set }
    var onGameOver: ((Int) -> Void)? { get set }
    var onDirectionChange: ((Direction) -> Void)? { get set }
    var onCollision: (() -> Void)? { get set }
    
    /// 游戏控制
    func start()
    func pause()
    func resume()
    func resetGame()
    func changeDirection(_ direction: Direction)
    func setDifficulty(_ difficulty: Difficulty)
    
    /// 位置判断
    func isSnakeHead(at point: Point) -> Bool
    func isSnakeBody(at point: Point) -> Bool
    func isFood(at point: Point) -> Bool
}

/// 默认游戏引擎实现
public class DefaultGameEngine: GameEngine {
    // MARK: - 游戏数据
    
    public private(set) var snake: [Point] = []
    public private(set) var food: Point?
    public private(set) var score = 0
    
    // MARK: - 回调
    
    public var onScoreUpdate: ((Int) -> Void)?
    public var onGameOver: ((Int) -> Void)?
    public var onDirectionChange: ((Direction) -> Void)?
    public var onCollision: (() -> Void)?
    
    // MARK: - 私有属性
    
    private var currentDirection: Direction = .right
    private var nextDirection: Direction = .right
    private var difficulty: Difficulty = .medium
    private var gameTimer: Timer?
    
    // MARK: - 初始化
    
    public init() {}
    
    // MARK: - 游戏控制
    
    public func start() {
        startTimer()
    }
    
    public func pause() {
        stopTimer()
    }
    
    public func resume() {
        startTimer()
    }
    
    public func resetGame() {
        stopTimer()
        
        // 重置游戏状态
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
    
    public func changeDirection(_ direction: Direction) {
        // 防止直接反向移动
        if direction != currentDirection.opposite {
            nextDirection = direction
        }
    }
    
    public func setDifficulty(_ difficulty: Difficulty) {
        self.difficulty = difficulty
        
        // 如果计时器正在运行，需要重启以应用新的速度
        if gameTimer != nil {
            startTimer()
        }
    }
    
    // MARK: - 位置判断
    
    public func isSnakeHead(at point: Point) -> Bool {
        return snake.first == point
    }
    
    public func isSnakeBody(at point: Point) -> Bool {
        return snake.contains(point) && snake.first != point
    }
    
    public func isFood(at point: Point) -> Bool {
        return food == point
    }
    
    // MARK: - 私有方法
    
    private func startTimer() {
        stopTimer()
        gameTimer = Timer.scheduledTimer(
            withTimeInterval: difficulty.moveInterval,
            repeats: true
        ) { [weak self] _ in
            self?.moveSnake()
        }
    }
    
    private func stopTimer() {
        gameTimer?.invalidate()
        gameTimer = nil
    }
    
    private func moveSnake() {
        // 更新方向
        currentDirection = nextDirection
        onDirectionChange?(currentDirection)
        
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
            onCollision?()
            onGameOver?(score)
            stopTimer()
            return
        }
        
        // 移动蛇
        snake.insert(newHead, at: 0)
        
        // 检查是否吃到食物
        if let foodPoint = food, newHead == foodPoint {
            // 吃到食物，增加分数，生成新食物
            score += 10
            generateFood()
            onScoreUpdate?(score)
        } else {
            // 没有吃到食物，移除尾部
            snake.removeLast()
        }
    }
    
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
    
    deinit {
        stopTimer()
    }
}