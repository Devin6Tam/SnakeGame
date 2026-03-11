import SwiftUI
import View

/// 应用入口（Controller层）
public struct SnakeGameApp: App {
    public init() {}
    
    public var body: some Scene {
        WindowGroup {
            SnakeGameView()
                // 移除固定的最小尺寸，让窗口自适应
                .frame(minWidth: 320, minHeight: 500)
        }
        .windowResizability(.contentSize)
    }
}
