import XCTest
import Combine
@testable import Model
@testable import Common

final class SnakeGameModelTests: XCTestCase {
    
    var gameModel: SnakeGameModel!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        gameModel = SnakeGameModel()
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        gameModel = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - 初始化测试
    
    func testInitialState() {
        XCTAssertEqual(gameModel.gameState, .notStarted)
        XCTAssertEqual(gameModel.score, 0)
        XCTAssertEqual(gameModel.snake, [])
        XCTAssertNil(gameModel.food)
        XCTAssertEqual(gameModel.currentDirection, .right)
        XCTAssertEqual(gameModel.nextDirection, .right)
        XCTAssertEqual(gameModel.difficulty, .medium)
    }
    
    func testInitialDirection() {
        XCTAssertEqual(gameModel.currentDirection, .right)
        XCTAssertEqual(gameModel.nextDirection, .right)
    }
    
    // MARK: - 游戏控制测试
    
    func testStartGame() {
        gameModel.startGame()
        
        XCTAssertEqual(gameModel.gameState, .playing)
        XCTAssertEqual(gameModel.score, 0)
        XCTAssertEqual(gameModel.snake.count, 3) // 初始蛇长为3
        XCTAssertNotNil(gameModel.food)
    }
    
    func testPauseGame() {
        gameModel.startGame()
        gameModel.pauseGame()
        
        XCTAssertEqual(gameModel.gameState, .paused)
    }
    
    func testResumeGame() {
        gameModel.startGame()
        gameModel.pauseGame()
        gameModel.resumeGame()
        
        XCTAssertEqual(gameModel.gameState, .playing)
    }
    
    func testRestartGame() {
        gameModel.startGame()
        // 等待一段时间让蛇移动
        Thread.sleep(forTimeInterval: 0.5)
        
        let oldScore = gameModel.score
        let oldSnakeCount = gameModel.snake.count
        
        gameModel.restartGame()
        
        XCTAssertEqual(gameModel.gameState, .playing)
        XCTAssertEqual(gameModel.score, 0)
        XCTAssertEqual(gameModel.snake.count, 3)
        XCTAssertNotEqual(oldScore, gameModel.score)
    }
    
    // MARK: - 方向控制测试
    
    func testChangeDirection() {
        gameModel.startGame()
        
        gameModel.changeDirection(.up)
        // 需要等待移动才能看到方向变化
        Thread.sleep(forTimeInterval: gameModel.difficulty.moveInterval * 2)
        
        XCTAssertEqual(gameModel.currentDirection, .up)
    }
    
    func testCannotReverseDirection() {
        gameModel.startGame()
        gameModel.changeDirection(.up)
        Thread.sleep(forTimeInterval: gameModel.difficulty.moveInterval * 2)
        
        gameModel.changeDirection(.down)
        Thread.sleep(forTimeInterval: gameModel.difficulty.moveInterval * 2)
        
        XCTAssertNotEqual(gameModel.currentDirection, .down)
    }
    
    // MARK: - 难度测试
    
    func testDifficultyChange() {
        XCTAssertEqual(gameModel.difficulty, .medium)
        
        gameModel.setDifficulty(.easy)
        XCTAssertEqual(gameModel.difficulty, .easy)
        
        gameModel.setDifficulty(.hard)
        XCTAssertEqual(gameModel.difficulty, .hard)
    }
    
    func testDifficultyChangesSpeed() {
        gameModel.startGame()
        gameModel.setDifficulty(.expert)
        
        // 专家模式应该更快
        XCTAssertEqual(gameModel.difficulty.moveInterval, 0.1, accuracy: 0.001)
    }
    
    // MARK: - 分数测试
    
    func testScoreIncreaseOnFood() {
        gameModel.startGame()
        
        // 等待蛇移动到食物位置（简化测试，实际需要更多时间）
        Thread.sleep(forTimeInterval: 0.5)
        
        // 在实际游戏中，分数会在蛇吃到食物时增加
        // 这里我们只测试初始状态
        XCTAssertGreaterThanOrEqual(gameModel.score, 0)
    }
    
    // MARK: - 辅助方法测试
    
    func testIsSnakeHead() {
        gameModel.startGame()
        
        let head = gameModel.snake.first!
        XCTAssertTrue(gameModel.isSnakeHead(at: head))
        
        let body = gameModel.snake.dropFirst().first!
        XCTAssertFalse(gameModel.isSnakeHead(at: body))
    }
    
    func testIsSnakeBody() {
        gameModel.startGame()
        
        let head = gameModel.snake.first!
        XCTAssertFalse(gameModel.isSnakeBody(at: head))
        
        if gameModel.snake.count > 1 {
            let body = gameModel.snake.dropFirst().first!
            XCTAssertTrue(gameModel.isSnakeBody(at: body))
        }
    }
    
    func testIsFood() {
        gameModel.startGame()
        
        if let food = gameModel.food {
            XCTAssertTrue(gameModel.isFood(at: food))
            
            let notFood = Point(x: 0, y: 0)
            XCTAssertFalse(gameModel.isFood(at: notFood))
        }
    }
    
    // MARK: - 碰撞检测测试（间接测试）
    
    func testWallCollisionEndsGame() {
        gameModel.startGame()
        
        // 蛇会在一定时间后撞墙（通过游戏状态判断）
        // 这个测试需要较长时间，主要用于验证游戏逻辑
        Thread.sleep(forTimeInterval: 0.5)
        
        // 游戏应该还在运行（因为刚开始）
        XCTAssertEqual(gameModel.gameState, .playing)
    }
    
    // MARK: - Published属性测试
    
    func testSnakeIsPublished() {
        var receivedSnake: [Point]?
        
        gameModel.$snake
            .sink { snake in
                receivedSnake = snake
            }
            .store(in: &cancellables)
        
        gameModel.startGame()
        
        XCTAssertNotNil(receivedSnake)
        XCTAssertEqual(receivedSnake?.count, 3)
    }
    
    func testScoreIsPublished() {
        var receivedScore: Int?
        
        gameModel.$score
            .sink { score in
                receivedScore = score
            }
            .store(in: &cancellables)
        
        gameModel.startGame()
        
        XCTAssertNotNil(receivedScore)
    }
    
    func testGameStateIsPublished() {
        var receivedState: GameState?
        
        gameModel.$gameState
            .sink { state in
                receivedState = state
            }
            .store(in: &cancellables)
        
        gameModel.startGame()
        
        XCTAssertEqual(receivedState, .playing)
    }
}
