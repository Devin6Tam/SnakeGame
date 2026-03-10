import XCTest
@testable import Common

final class PointTests: XCTestCase {
    
    func testPointEquality() {
        let point1 = Point(x: 5, y: 10)
        let point2 = Point(x: 5, y: 10)
        let point3 = Point(x: 6, y: 10)
        
        XCTAssertEqual(point1, point2)
        XCTAssertNotEqual(point1, point3)
    }
    
    func testPointHash() {
        let point1 = Point(x: 3, y: 7)
        let point2 = Point(x: 3, y: 7)
        
        var hasher1 = Hasher()
        hasher1.combine(point1.x)
        hasher1.combine(point1.y)
        
        var hasher2 = Hasher()
        hasher2.combine(point2.x)
        hasher2.combine(point2.y)
        
        XCTAssertEqual(point1.hashValue, point2.hashValue)
    }
    
    func testPointInSet() {
        var set: Set<Point> = []
        set.insert(Point(x: 1, y: 2))
        set.insert(Point(x: 3, y: 4))
        set.insert(Point(x: 1, y: 2)) // 重复
        
        XCTAssertEqual(set.count, 2)
        XCTAssertTrue(set.contains(Point(x: 1, y: 2)))
        XCTAssertTrue(set.contains(Point(x: 3, y: 4)))
        XCTAssertFalse(set.contains(Point(x: 5, y: 6)))
    }
    
    func testPointInitialization() {
        let point = Point(x: 10, y: 20)
        XCTAssertEqual(point.x, 10)
        XCTAssertEqual(point.y, 20)
    }
}
