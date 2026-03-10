import XCTest
@testable import View
@testable import Common

final class ViewTests: XCTestCase {
    
    func testViewInitialization() {
        // 测试 SnakeGameView 可以正确初始化
        let view = SnakeGameView()
        XCTAssertNotNil(view)
    }
    
    func testViewBodyProducesValidView() {
        let view = SnakeGameView()
        let body = view.body
        
        // 验证 body 不为空
        // 注意：由于 SwiftUI View 是一个协议，这里主要测试编译
        XCTAssertNotNil(body)
    }
}

final class ColorSchemeTests: XCTestCase {
    
    // 测试配色方案的颜色都是有效的
    func testColorSchemeValuesAreValid() {
        // 这里主要验证代码能正确编译¨
        let _ = ColorScheme.snakeHead
        let _ = ColorScheme.snakeBody
        let _ = ColorScheme.food
        let _ = ColorScheme.gridBackground
        let _ = ColorScheme.gridLine
        let _ = ColorScheme.appBackground
    }
    
    func testButtonColorsAreDefined() {
        let _ = ColorScheme.buttonPrimary
        let _ = ColorScheme.buttonSuccess
        let _ = ColorScheme.buttonWarning
        let _ = ColorScheme.buttonDanger
        let _ = ColorScheme.buttonRestart
    }
    
    func testStatusColorsAreDefined() {
        let _ = ColorScheme.statusPlaying
        let _ = ColorScheme.statusPaused
        let _ = ColorScheme.statusGameOver
        let _ = ColorScheme.statusNotStarted
    }
}
