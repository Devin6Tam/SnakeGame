import Foundation

/// 游戏方向枚举
public enum Direction: CaseIterable {
    case up, down, left, right
    
    /// 获取相反的方向
    public var opposite: Direction {
        switch self {
        case .up: return .down
        case .down: return .up
        case .left: return .right
        case .right: return .left
        }
    }
}
