import SwiftUI
import Combine
import Foundation

/// 蛇皮肤配置模型
public struct SnakeSkin {
    public let name: String
    public let description: String
    
    // 颜色配置
    public let headColor: Color
    public let bodyColor: Color
    public let eyeColor: Color
    public let gradientColors: [Color]
    
    // 纹理配置
    public let hasTexture: Bool
    public let textureScale: CGFloat
    public let textureOpacity: CGFloat
    
    // 动画配置
    public let hasEyesBlink: Bool
    public let blinkInterval: TimeInterval
    public let bodySwing: Bool
    public let swingIntensity: CGFloat
    
    public init(name: String, 
                description: String,
                headColor: Color,
                bodyColor: Color,
                eyeColor: Color = .white,
                gradientColors: [Color] = [],
                hasTexture: Bool = false,
                textureScale: CGFloat = 1.0,
                textureOpacity: CGFloat = 0.3,
                hasEyesBlink: Bool = true,
                blinkInterval: TimeInterval = 3.0,
                bodySwing: Bool = true,
                swingIntensity: CGFloat = 0.8) {
        self.name = name
        self.description = description
        self.headColor = headColor
        self.bodyColor = bodyColor
        self.eyeColor = eyeColor
        self.gradientColors = gradientColors
        self.hasTexture = hasTexture
        self.textureScale = textureScale
        self.textureOpacity = textureOpacity
        self.hasEyesBlink = hasEyesBlink
        self.blinkInterval = blinkInterval
        self.bodySwing = bodySwing
        self.swingIntensity = swingIntensity
    }
}

/// 预设皮肤集合
public enum SnakeSkinPreset {
    case classic     // 经典绿蛇
    case rainbow     // 彩虹蛇
    case fire        // 火焰蛇
    case ice         // 冰雪蛇
    case golden      // 黄金蛇
    case shadow      // 暗影蛇
    
    public var skin: SnakeSkin {
        switch self {
        case .classic:
            return SnakeSkin(
                name: "经典绿蛇",
                description: "传统的绿色蛇皮肤",
                headColor: Color(red: 0.2, green: 0.8, blue: 0.2),
                bodyColor: Color(red: 0.3, green: 0.9, blue: 0.3),
                eyeColor: .white
            )
            
        case .rainbow:
            return SnakeSkin(
                name: "彩虹蛇",
                description: "七彩渐变效果的蛇",
                headColor: .red,
                bodyColor: .purple,
                gradientColors: [
                    .red, .orange, .yellow, .green, .blue, .purple
                ],
                hasTexture: true,
                textureOpacity: 0.4
            )
            
        case .fire:
            return SnakeSkin(
                name: "火焰蛇",
                description: "炽热的火焰效果",
                headColor: Color(red: 1.0, green: 0.3, blue: 0.1),
                bodyColor: Color(red: 1.0, green: 0.6, blue: 0.1),
                gradientColors: [
                    Color(red: 1.0, green: 0.1, blue: 0.0),
                    Color(red: 1.0, green: 0.5, blue: 0.0),
                    Color(red: 1.0, green: 0.8, blue: 0.0)
                ],
                hasTexture: true,
                textureOpacity: 0.5
            )
            
        case .ice:
            return SnakeSkin(
                name: "冰雪蛇",
                description: "冰冷的冰雪效果",
                headColor: Color(red: 0.7, green: 0.9, blue: 1.0),
                bodyColor: Color(red: 0.8, green: 0.95, blue: 1.0),
                gradientColors: [
                    Color(red: 0.6, green: 0.8, blue: 1.0),
                    Color(red: 0.8, green: 0.95, blue: 1.0),
                    Color(red: 0.9, green: 0.98, blue: 1.0)
                ],
                hasTexture: true,
                textureOpacity: 0.6
            )
            
        case .golden:
            return SnakeSkin(
                name: "黄金蛇",
                description: "闪耀的黄金蛇",
                headColor: Color(red: 1.0, green: 0.84, blue: 0.0),
                bodyColor: Color(red: 1.0, green: 0.9, blue: 0.3),
                eyeColor: .black,
                gradientColors: [
                    Color(red: 0.9, green: 0.7, blue: 0.0),
                    Color(red: 1.0, green: 0.84, blue: 0.0),
                    Color(red: 1.0, green: 0.95, blue: 0.5)
                ],
                hasTexture: true,
                textureOpacity: 0.4
            )
            
        case .shadow:
            return SnakeSkin(
                name: "暗影蛇",
                description: "神秘的暗影效果",
                headColor: Color(red: 0.1, green: 0.1, blue: 0.2),
                bodyColor: Color(red: 0.2, green: 0.2, blue: 0.3),
                eyeColor: Color(red: 0.8, green: 0.2, blue: 0.8),
                gradientColors: [
                    Color(red: 0.05, green: 0.05, blue: 0.1),
                    Color(red: 0.2, green: 0.2, blue: 0.3),
                    Color(red: 0.3, green: 0.3, blue: 0.4)
                ],
                hasTexture: true,
                textureOpacity: 0.7
            )
        }
    }
}

/// 蛇皮肤管理器
@MainActor
public class SnakeSkinManager: ObservableObject {
    @Published public var currentSkin: SnakeSkin
    @Published public var availableSkins: [SnakeSkin]
    
    public init() {
        // 先初始化 availableSkins
        let skins = [
            SnakeSkinPreset.classic.skin,
            SnakeSkinPreset.rainbow.skin,
            SnakeSkinPreset.fire.skin,
            SnakeSkinPreset.ice.skin,
            SnakeSkinPreset.golden.skin,
            SnakeSkinPreset.shadow.skin
        ]
        
        self.availableSkins = skins
        self.currentSkin = skins.first!
    }
    
    public func changeSkin(to skin: SnakeSkin) {
        currentSkin = skin
    }
    
    public func getSkinByName(_ name: String) -> SnakeSkin? {
        return availableSkins.first { $0.name == name }
    }
}

/// 蛇特效管理器 - 负责处理游戏中的视觉效果
@MainActor
public class SnakeEffectsManager: ObservableObject {
    @Published public var foodEatenEffect: FoodEatenEffect?
    @Published public var collisionEffect: CollisionEffect?
    @Published public var scoreEffect: ScoreEffect?
    
    public init() {}
    
    public func triggerFoodEatenEffect(at point: Point) {
        foodEatenEffect = FoodEatenEffect(position: point)
        
        // 自动清除效果
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { @Sendable [weak self] in
            guard let self = self else { return }
            withAnimation(.easeOut(duration: 0.3)) {
                self.foodEatenEffect = nil
            }
        }
    }
    
    public func triggerCollisionEffect() {
        collisionEffect = CollisionEffect()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { @Sendable [weak self] in
            guard let self = self else { return }
            withAnimation(.easeOut(duration: 0.3)) {
                self.collisionEffect = nil
            }
        }
    }
    
    public func triggerScoreEffect(score: Int) {
        scoreEffect = ScoreEffect(score: score)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { @Sendable [weak self] in
            guard let self = self else { return }
            withAnimation(.easeOut(duration: 0.3)) {
                self.scoreEffect = nil
            }
        }
    }
}

/// 食物被吃特效
public struct FoodEatenEffect: Identifiable {
    public let id = UUID()
    public let position: Point
    public var scale: CGFloat = 1.0
    public var opacity: Double = 1.0
    
    public init(position: Point) {
        self.position = position
    }
}

/// 碰撞特效
public struct CollisionEffect: Identifiable {
    public let id = UUID()
    public var scale: CGFloat = 1.0
    public var opacity: Double = 1.0
    
    public init() {}
}

/// 分数特效
public struct ScoreEffect: Identifiable {
    public let id = UUID()
    public let score: Int
    public var offsetY: CGFloat = 0
    public var opacity: Double = 1.0
    
    public init(score: Int) {
        self.score = score
    }
}
