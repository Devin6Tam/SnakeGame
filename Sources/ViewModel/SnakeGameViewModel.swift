import Foundation
import Combine
import Common
import Engine
import Services

/// 游戏事件枚举
public enum GameEvent {
    case started
    case paused
    case resumed
    case ended(score: Int)
    case directionChanged(Direction)
    case difficultyChanged(Difficulty)
    case foodEaten(score: Int)
    case collisionDetected
    case skinChanged(SnakeSkin)
}

/// 贪吃蛇游戏视图模型（ViewModel层）
/// 职责：处理游戏逻辑和状态转换
@MainActor
public class SnakeGameViewModel: ObservableObject {
    // MARK: - 发布属性
    
    /// 游戏状态
    @Published public private(set) var gameState: GameState = .notStarted
    
    /// 当前分数
    @Published public private(set) var score = 0
    
    /// 最高分
    @Published public private(set) var highScore = 0
    
    /// 当前移动方向
    @Published public private(set) var currentDirection: Direction = .right
    
    /// 难度等级
    @Published public var difficulty: Difficulty = .medium
    
    /// 当前皮肤
    @Published public private(set) var currentSkin: SnakeSkin
    
    /// 可用皮肤列表
    @Published public private(set) var availableSkins: [SnakeSkin]
    
    /// 蛇皮肤管理器
    private let skinManager: SnakeSkinManager
    
    /// 特效管理器
    @MainActor public let effectsManager = SnakeEffectsManager()
    
    /// 游戏事件发布器
    public let eventPublisher = PassthroughSubject<GameEvent, Never>()
    
    // MARK: - 私有属性
    
    /// 游戏引擎 - 处理核心游戏逻辑
    private var gameEngine: GameEngine
    
    /// 游戏服务 - 处理数据持久化等
    private let gameService: GameService
    
    /// 下次移动方向（用于防止快速按键导致的冲突）
    private var nextDirection: Direction = .right
    
    // MARK: - 初始化
    
    public init(gameEngine: GameEngine = DefaultGameEngine(), 
                gameService: GameService = DefaultGameService(),
                skinManager: SnakeSkinManager = SnakeSkinManager()) {
        self.gameEngine = gameEngine
        self.gameService = gameService
        self.skinManager = skinManager
        
        // 必须在所有存储属性初始化后才能访问 self
        self.currentSkin = skinManager.currentSkin
        self.availableSkins = skinManager.availableSkins
        
        // 加载保存的数据
        loadSavedData()
        
        // 设置游戏引擎回调
        setupGameEngineCallbacks()
    }
    
    // MARK: - 游戏控制方法
    
    /// 开始游戏
    public func startGame() {
        gameEngine.resetGame()
        gameState = .playing
        gameEngine.start()
        eventPublisher.send(.started)
    }
    
    /// 暂停游戏
    public func pauseGame() {
        if gameState == .playing {
            gameState = .paused
            gameEngine.pause()
            eventPublisher.send(.paused)
        }
    }
    
    /// 继续游戏
    public func resumeGame() {
        if gameState == .paused {
            gameState = .playing
            gameEngine.resume()
            eventPublisher.send(.resumed)
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
            gameEngine.changeDirection(direction)
            eventPublisher.send(.directionChanged(direction))
        }
    }
    
    /// 设置难度等级
    public func setDifficulty(_ difficulty: Difficulty) {
        self.difficulty = difficulty
        gameService.saveDifficulty(difficulty)
        
        // 如果游戏正在运行，需要重启游戏引擎以应用新的速度
        if gameState == .playing {
            gameEngine.setDifficulty(difficulty)
        }
        
        eventPublisher.send(.difficultyChanged(difficulty))
    }
    
    /// 改变蛇皮肤
    public func changeSkin(_ skin: SnakeSkin) {
        skinManager.changeSkin(to: skin)
        currentSkin = skin
        eventPublisher.send(.skinChanged(skin))
    }
    
    /// 获取下一个皮肤（循环切换）
    public func nextSkin() {
        guard let currentIndex = availableSkins.firstIndex(where: { $0.name == currentSkin.name }) else { return }
        let nextIndex = (currentIndex + 1) % availableSkins.count
        changeSkin(availableSkins[nextIndex])
    }
    
    /// 获取上一个皮肤（循环切换）
    public func previousSkin() {
        guard let currentIndex = availableSkins.firstIndex(where: { $0.name == currentSkin.name }) else { return }
        let previousIndex = (currentIndex - 1 + availableSkins.count) % availableSkins.count
        changeSkin(availableSkins[previousIndex])
    }
    
    // MARK: - 游戏数据访问
    
    /// 获取蛇身位置
    public var snake: [Point] {
        return gameEngine.snake
    }
    
    /// 获取食物位置
    public var food: Point? {
        return gameEngine.food
    }
    
    /// 判断指定位置是否是蛇头
    public func isSnakeHead(at point: Point) -> Bool {
        return gameEngine.isSnakeHead(at: point)
    }
    
    /// 判断指定位置是否是蛇身
    public func isSnakeBody(at point: Point) -> Bool {
        return gameEngine.isSnakeBody(at: point)
    }
    
    /// 判断指定位置是否有食物
    public func isFood(at point: Point) -> Bool {
        return gameEngine.isFood(at: point)
    }
    
    // MARK: - 私有方法
    
    /// 加载保存的数据
    private func loadSavedData() {
        highScore = gameService.loadHighScore()
        
        if let savedDifficulty = gameService.loadDifficulty() {
            difficulty = savedDifficulty
        }
    }
    
    /// 设置游戏引擎回调
    private func setupGameEngineCallbacks() {
        gameEngine.onScoreUpdate = { [weak self] (newScore: Int) in
            guard let self = self else { return }
            self.score = newScore
            
            // 更新最高分
            if newScore > self.highScore {
                self.highScore = newScore
                self.gameService.saveHighScore(newScore)
            }
            
            // 触发分数特效
            if newScore > 0 {
                Task { @MainActor in
                    self.effectsManager.triggerScoreEffect(score: newScore)
                }
            }
            
            self.eventPublisher.send(.foodEaten(score: newScore))
        }
        
        gameEngine.onGameOver = { [weak self] (finalScore: Int) in
            guard let self = self else { return }
            self.gameState = .gameOver
            
            // 触发碰撞特效
            Task { @MainActor in
                self.effectsManager.triggerCollisionEffect()
            }
            
            self.eventPublisher.send(.ended(score: finalScore))
        }
        
        gameEngine.onDirectionChange = { [weak self] (newDirection: Direction) in
            guard let self = self else { return }
            self.currentDirection = newDirection
        }
        
        gameEngine.onCollision = { [weak self] in
            guard let self = self else { return }
            self.eventPublisher.send(.collisionDetected)
        }
    }
}