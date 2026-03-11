import Foundation
import Common

/// 贪吃蛇游戏数据模型（Model层）
/// 职责：纯数据结构，不包含任何业务逻辑
public struct SnakeGameModel {
    // MARK: - 游戏数据
    
    /// 蛇身位置数组
    public var snake: [Point]
    
    /// 食物位置
    public var food: Point?
    
    /// 当前分数
    public var score: Int
    
    /// 当前移动方向
    public var currentDirection: Direction
    
    /// 游戏状态
    public var gameState: GameState
    
    // MARK: - 初始化
    
    public init(snake: [Point] = [], 
                food: Point? = nil, 
                score: Int = 0, 
                currentDirection: Direction = .right, 
                gameState: GameState = .notStarted) {
        self.snake = snake
        self.food = food
        self.score = score
        self.currentDirection = currentDirection
        self.gameState = gameState
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
    
    /// 创建初始游戏状态
    public static func initialGameState() -> SnakeGameModel {
        return SnakeGameModel(
            snake: [
                Point(x: GameConfig.gridWidth / 2, y: GameConfig.gridHeight / 2),
                Point(x: GameConfig.gridWidth / 2 - 1, y: GameConfig.gridHeight / 2),
                Point(x: GameConfig.gridWidth / 2 - 2, y: GameConfig.gridHeight / 2)
            ],
            food: nil,
            score: 0,
            currentDirection: .right,
            gameState: .notStarted
        )
    }
}
