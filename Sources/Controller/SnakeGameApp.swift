import SwiftUI
import View

/// 应用入口（Controller层）
public struct SnakeGameApp: App {
    public init() {}
    
    public var body: some Scene {
        WindowGroup {
            SnakeGameView()
                .frame(minWidth: 600, minHeight: 800)
        }
    }
}
