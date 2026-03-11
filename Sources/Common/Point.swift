import Foundation

/// 游戏网格上的点
public struct Point: Hashable, Equatable {
    public let x: Int
    public let y: Int
    
    public init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
}
