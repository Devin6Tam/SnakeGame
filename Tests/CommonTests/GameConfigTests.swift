import XCTest
@testable import Common

final class GameConfigTests: XCTestCase {
    
    func testGridDimensions() {
        XCTAssertEqual(GameConfig.gridWidth, 20)
        XCTAssertEqual(GameConfig.gridHeight, 20)
    }
    
    func testGridIsSquare() {
        XCTAssertEqual(GameConfig.gridWidth, GameConfig.gridHeight)
    }
    
    func testGridSizeIsPositive() {
        XCTAssertGreaterThan(GameConfig.gridWidth, 0)
        XCTAssertGreaterThan(GameConfig.gridHeight, 0)
    }
}
