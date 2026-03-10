import XCTest
@testable import Common

final class DifficultyTests: XCTestCase {
    
    func testDifficultyMoveIntervals() {
        XCTAssertEqual(Difficulty.easy.moveInterval, 0.4, accuracy: 0.001)
        XCTAssertEqual(Difficulty.medium.moveInterval, 0.25, accuracy: 0.001)
        XCTAssertEqual(Difficulty.hard.moveInterval, 0.15, accuracy: 0.001)
        XCTAssertEqual(Difficulty.expert.moveInterval, 0.1, accuracy: 0.001)
    }
    
    func testDifficultyDescriptions() {
        XCTAssertEqual(Difficulty.easy.description, "轻松休闲")
        XCTAssertEqual(Difficulty.medium.description, "适合新手")
        XCTAssertEqual(Difficulty.hard.description, "挑战自我")
        XCTAssertEqual(Difficulty.expert.description, "极限挑战")
    }
    
    func testDifficultyRawValues() {
        XCTAssertEqual(Difficulty.easy.rawValue, "简单")
        XCTAssertEqual(Difficulty.medium.rawValue, "中等")
        XCTAssertEqual(Difficulty.hard.rawValue, "困难")
        XCTAssertEqual(Difficulty.expert.rawValue, "专家")
    }
    
    func testDifficultyAllCases() {
        XCTAssertEqual(Difficulty.allCases.count, 4)
        XCTAssertEqual(Difficulty.allCases[0], .easy)
        XCTAssertEqual(Difficulty.allCases[1], .medium)
        XCTAssertEqual(Difficulty.allCases[2], .hard)
        XCTAssertEqual(Difficulty.allCases[3], .expert)
    }
    
    func testDifficultySpeedComparison() {
        XCTAssertTrue(Difficulty.easy.moveInterval > Difficulty.medium.moveInterval)
        XCTAssertTrue(Difficulty.medium.moveInterval > Difficulty.hard.moveInterval)
        XCTAssertTrue(Difficulty.hard.moveInterval > Difficulty.expert.moveInterval)
    }
}
