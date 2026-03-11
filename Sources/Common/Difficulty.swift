import Foundation
import SwiftUI

/// 难度等级
public enum Difficulty: String, CaseIterable {
    case easy = "简单"
    case medium = "中等"
    case hard = "困难"
    case expert = "专家"
    
    /// 移动间隔（秒）
    public var moveInterval: TimeInterval {
        switch self {
        case .easy: return 0.4
        case .medium: return 0.25
        case .hard: return 0.15
        case .expert: return 0.1
        }
    }
    
    /// 难度描述
    public var description: String {
        switch self {
        case .easy: return "轻松休闲"
        case .medium: return "适合新手"
        case .hard: return "挑战自我"
        case .expert: return "极限挑战"
        }
    }
}
