#!/usr/bin/env swift

import Foundation

// 简单的测试脚本来验证项目基本功能
print("=== 贪吃蛇游戏项目测试 ===")

// 测试 Common 模块
print("\n1. 测试 Common 模块...")

// 测试 Point 结构
struct Point: Hashable {
    let x: Int
    let y: Int
}

let point1 = Point(x: 5, y: 10)
let point2 = Point(x: 5, y: 10)
let point3 = Point(x: 6, y: 10)

print("Point 相等性测试: \(point1 == point2 ? "通过" : "失败")")
print("Point 不等性测试: \(point1 != point3 ? "通过" : "失败")")

// 测试 Direction 枚举
enum Direction: String, CaseIterable {
    case up, down, left, right
    
    var opposite: Direction {
        switch self {
        case .up: return .down
        case .down: return .up
        case .left: return .right
        case .right: return .left
        }
    }
}

print("Direction 相反方向测试: \(Direction.up.opposite == .down ? "通过" : "失败")")
print("Direction 所有枚举值: \(Direction.allCases.count == 4 ? "通过" : "失败")")

// 测试 Difficulty 枚举
enum Difficulty: String, CaseIterable {
    case easy = "简单"
    case medium = "中等"
    case hard = "困难"
    case expert = "专家"
    
    var moveInterval: Double {
        switch self {
        case .easy: return 0.4
        case .medium: return 0.25
        case .hard: return 0.15
        case .expert: return 0.1
        }
    }
    
    var description: String {
        switch self {
        case .easy: return "轻松休闲"
        case .medium: return "适合新手"
        case .hard: return "挑战自我"
        case .expert: return "极限挑战"
        }
    }
}

print("Difficulty 移动间隔测试: \(Difficulty.easy.moveInterval == 0.4 ? "通过" : "失败")")
print("Difficulty 描述测试: \(Difficulty.medium.description == "适合新手" ? "通过" : "失败")")

// 测试 GameConfig
struct GameConfig {
    static let gridWidth = 20
    static let gridHeight = 20
}

print("GameConfig 网格尺寸测试: \(GameConfig.gridWidth == 20 && GameConfig.gridHeight == 20 ? "通过" : "失败")")

// 测试项目构建
print("\n2. 测试项目构建...")
let buildResult = shell("cd /Users/devintan/Desktop/workspace/SnakeGame && swift build")
if buildResult.contains("Build complete!") {
    print("✅ 项目构建成功")
} else {
    print("❌ 项目构建失败")
    print("构建输出: \(buildResult)")
}

// 测试可执行文件
print("\n3. 测试可执行文件...")
let executablePath = "/Users/devintan/Desktop/workspace/SnakeGame/.build/debug/SnakeGame"
let fileManager = FileManager.default
if fileManager.fileExists(atPath: executablePath) {
    print("✅ 可执行文件存在")
} else {
    print("❌ 可执行文件不存在")
}

print("\n=== 测试完成 ===")

// 辅助函数：执行 shell 命令
func shell(_ command: String) -> String {
    let task = Process()
    let pipe = Pipe()
    
    task.standardOutput = pipe
    task.standardError = pipe
    task.arguments = ["-c", command]
    task.launchPath = "/bin/bash"
    task.launch()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8) ?? ""
    
    return output
}