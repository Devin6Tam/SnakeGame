import SwiftUI
import Common

/// 特效渲染器
public struct SnakeEffectsRenderer: View {
    @ObservedObject var effectsManager: SnakeEffectsManager
    let gridSize: CGFloat
    
    private let gridWidth = GameConfig.gridWidth
    private let gridHeight = GameConfig.gridHeight
    
    public init(effectsManager: SnakeEffectsManager, gridSize: CGFloat) {
        self.effectsManager = effectsManager
        self.gridSize = gridSize
    }
    
    public var body: some View {
        ZStack {
            // 食物被吃特效
            if let foodEffect = effectsManager.foodEatenEffect {
                FoodEatenEffectView(effect: foodEffect, gridSize: gridSize)
            }
            
            // 碰撞特效
            if let collisionEffect = effectsManager.collisionEffect {
                CollisionEffectView(effect: collisionEffect, gridSize: gridSize)
            }
            
            // 分数特效
            if let scoreEffect = effectsManager.scoreEffect {
                ScoreEffectView(effect: scoreEffect)
            }
        }
        .frame(width: gridSize, height: gridSize)
    }
}

/// 食物被吃特效视图
private struct FoodEatenEffectView: View {
    @State var effect: FoodEatenEffect
    let gridSize: CGFloat
    
    private let gridWidth = GameConfig.gridWidth
    private let gridHeight = GameConfig.gridHeight
    
    var body: some View {
        Canvas { context, size in
            let cellWidth = size.width / CGFloat(gridWidth)
            let cellHeight = size.height / CGFloat(gridHeight)
            
            let baseRect = CGRect(
                x: CGFloat(effect.position.x) * cellWidth,
                y: CGFloat(effect.position.y) * cellHeight,
                width: cellWidth,
                height: cellHeight
            )
            
            let colors = [Color.yellow, Color.orange, Color.red]
            
            // 粒子效果 - 简化表达式
            for i in 0..<8 {
                let angle = Double(i) * .pi / 4
                let distance = effect.scale * cellWidth * 0.8
                
                let xOffset = cos(angle) * distance
                let yOffset = sin(angle) * distance
                
                let particleX = baseRect.midX + xOffset - cellWidth / 8
                let particleY = baseRect.midY + yOffset - cellHeight / 8
                
                let particleRect = CGRect(
                    x: particleX,
                    y: particleY,
                    width: cellWidth / 4,
                    height: cellHeight / 4
                )
                
                let particlePath = Circle().path(in: particleRect)
                let colorIndex = i % colors.count
                let particleColor = colors[colorIndex].opacity(effect.opacity)
                
                context.fill(particlePath, with: .color(particleColor))
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                effect.scale = 2.0
                effect.opacity = 0.0
            }
        }
    }
}

/// 碰撞特效视图
private struct CollisionEffectView: View {
    @State var effect: CollisionEffect
    let gridSize: CGFloat
    
    var body: some View {
        Canvas { context, size in
            // 冲击波效果
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = min(size.width, size.height) * 0.4 * effect.scale
            
            let effectPath = Circle().path(in: CGRect(
                x: center.x - radius,
                y: center.y - radius,
                width: radius * 2,
                height: radius * 2
            ))
            
            let gradient = Gradient(colors: [
                Color.red.opacity(0.8),
                Color.orange.opacity(0.6),
                Color.yellow.opacity(0.4)
            ])
            
            context.fill(effectPath, with: .radialGradient(
                gradient,
                center: center,
                startRadius: 0,
                endRadius: radius
            ))
        }
        .onAppear {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                effect.scale = 1.5
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { @Sendable in
                Task { @MainActor in
                    withAnimation(.easeOut(duration: 0.5)) {
                        effect.scale = 0.5
                        effect.opacity = 0.0
                    }
                }
            }
        }
    }
}

/// 分数特效视图
private struct ScoreEffectView: View {
    @State var effect: ScoreEffect
    
    var body: some View {
        Text("+\\(effect.score)")
            .font(.title)
            .fontWeight(.bold)
            .foregroundColor(.yellow)
            .shadow(color: .orange, radius: 3)
            .offset(y: effect.offsetY)
            .opacity(effect.opacity)
            .onAppear {
                withAnimation(.easeOut(duration: 1.5)) {
                    effect.offsetY = -100
                    effect.opacity = 0.0
                }
            }
    }
}
