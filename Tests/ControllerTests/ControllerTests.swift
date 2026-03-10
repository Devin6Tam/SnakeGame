import XCTest
@testable import Controller

final class ControllerTests: XCTestCase {
    
    func testAppInitialization() {
        let app = SnakeGameApp()
        XCTAssertNotNil(app)
    }
    
    func testAppBodyProducesValidScene() {
        let app = SnakeGameApp()
        let body = app.body
        
        // 验证 body 不为空
        XCTAssertNotNil(body)
    }
}
