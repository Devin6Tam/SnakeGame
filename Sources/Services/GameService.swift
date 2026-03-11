import Foundation
import Common

/// 游戏服务协议
public protocol GameService {
    /// 最高分相关
    func saveHighScore(_ score: Int)
    func loadHighScore() -> Int
    
    /// 难度设置相关
    func saveDifficulty(_ difficulty: Difficulty)
    func loadDifficulty() -> Difficulty?
}

/// 默认游戏服务实现（基于UserDefaults）
public class DefaultGameService: GameService {
    
    private let highScoreKey = "snakeHighScore"
    private let difficultyKey = "snakeDifficulty"
    
    public init() {}
    
    // MARK: - 最高分管理
    
    public func saveHighScore(_ score: Int) {
        UserDefaults.standard.set(score, forKey: highScoreKey)
    }
    
    public func loadHighScore() -> Int {
        return UserDefaults.standard.integer(forKey: highScoreKey)
    }
    
    // MARK: - 难度管理
    
    public func saveDifficulty(_ difficulty: Difficulty) {
        UserDefaults.standard.set(difficulty.rawValue, forKey: difficultyKey)
    }
    
    public func loadDifficulty() -> Difficulty? {
        guard let difficultyString = UserDefaults.standard.string(forKey: difficultyKey) else {
            return nil
        }
        return Difficulty(rawValue: difficultyString)
    }
}