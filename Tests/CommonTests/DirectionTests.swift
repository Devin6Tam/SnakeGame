import XCTest
@testable import Common

final class DirectionTests: XCTestCase {
    
    func testDirectionOpposite() {
        XCTAssertEqual(Direction.up.opposite, .down)
        XCTAssertEqual(Direction.down.opposite, .up)
        XCTAssertEqual(Direction.left.opposite, .right)
        XCTAssertEqual(Direction.right.opposite, .left)
    }
    
    func testDirectionAllCases() {
        XCTAssertEqual(Direction.allCases.count, 4)
        XCTAssertTrue(Direction.allCases.contains(.up))
        XCTAssertTrue(Direction.allCases.contains(.down))
        XCTAssertTrue(Direction.allCases.contains(.left))
        XCTAssertTrue(Direction.allCases.contains(.right))
    }
    
    func testDirectionDoubleOpposite() {
        XCTAssertEqual(Direction.up.opposite.opposite, .up)
        XCTAssertEqual(Direction.down.opposite.opposite, .down)
        XCTAssertEqual(Direction.left.opposite.opposite, .left)
        XCTAssertEqual(Direction.right.opposite.opposite, .right)
    }
}
