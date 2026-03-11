import SwiftUI
import Common

/// 皮肤预览组件
public struct SkinPreview: View {
    let skin: SnakeSkin
    let isSelected: Bool
    let size: CGFloat
    
    public init(skin: SnakeSkin, isSelected: Bool, size: CGFloat = 60) {
        self.skin = skin
        self.isSelected = isSelected
        self.size = size
    }
    
    public var body: some View {
        VStack(spacing: 8) {
            // 皮肤预览图
            ZStack {
                // 背景
                RoundedRectangle(cornerRadius: 12)
                    .fill(ColorScheme.cardBackground)
                    .frame(width: size, height: size)
                
                // 蛇预览
                SnakePreviewRenderer(skin: skin, size: size - 20)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: isSelected ? 3 : 2)
            )
            
            // 皮肤名称
            Text(skin.name)
                .font(.caption)
                .fontWeight(isSelected ? .bold : .medium)
                .foregroundColor(textColor)
                .lineLimit(1)
        }
        .frame(width: size + 20)
    }
    
    private var borderColor: Color {
        isSelected ? ColorScheme.buttonPrimary : ColorScheme.gridLine.opacity(0.5)
    }
    
    private var textColor: Color {
        isSelected ? ColorScheme.textPrimary : ColorScheme.textSecondary
    }
}

/// 蛇预览渲染器
private struct SnakePreviewRenderer: View {
    let skin: SnakeSkin
    let size: CGFloat
    
    var body: some View {
        Canvas { context, canvasSize in
            let cellSize = canvasSize.width / 5
            
            // 绘制蛇预览（简化版）
            for i in 0..<3 {
                let rect = CGRect(
                    x: CGFloat(i) * cellSize + cellSize / 2,
                    y: canvasSize.height / 2,
                    width: cellSize,
                    height: cellSize
                )
                
                if i == 0 {
                    // 蛇头
                    drawSnakeHead(in: rect, context: context)
                } else {
                    // 蛇身
                    drawSnakeBody(in: rect, context: context, index: i)
                }
            }
        }
        .frame(width: size, height: size)
    }
    
    private func drawSnakeHead(in rect: CGRect, context: GraphicsContext) {
        let headPath = createSnakeHeadPath(in: rect)
        
        // 头部渐变
        let headGradient = Gradient(colors: [
            skin.headColor,
            skin.headColor.opacity(0.8),
            skin.bodyColor
        ])
        
        context.fill(headPath, with: .radialGradient(
            headGradient,
            center: CGPoint(x: rect.midX, y: rect.midY),
            startRadius: 0,
            endRadius: rect.width
        ))
        
        // 眼睛
        if skin.hasEyesBlink {
            drawEyes(in: rect, context: context)
        }
    }
    
    private func drawSnakeBody(in rect: CGRect, context: GraphicsContext, index: Int) {
        let bodyPath = createSnakeBodyPath(in: rect)
        
        // 身体颜色渐变
        let progress = CGFloat(index) / 2.0
        let bodyColor = interpolateColor(
            from: skin.headColor,
            to: skin.bodyColor,
            progress: progress
        )
        
        context.fill(bodyPath, with: .color(bodyColor))
        
        // 纹理
        if skin.hasTexture {
            drawBodyTexture(in: rect, context: context)
        }
    }
    
    private func createSnakeHeadPath(in rect: CGRect) -> Path {
        var path = Path()
        
        let radius = min(rect.width, rect.height) / 2 - 1
        let center = CGPoint(x: rect.midX, y: rect.midY)
        
        path.addEllipse(in: CGRect(
            x: center.x - radius,
            y: center.y - radius * 0.7,
            width: radius * 2,
            height: radius * 1.4
        ))
        
        return path
    }
    
    private func createSnakeBodyPath(in rect: CGRect) -> Path {
        var path = Path()
        
        let radius = min(rect.width, rect.height) / 2 - 1
        let center = CGPoint(x: rect.midX, y: rect.midY)
        
        path.addEllipse(in: CGRect(
            x: center.x - radius,
            y: center.y - radius * 0.8,
            width: radius * 2,
            height: radius * 1.6
        ))
        
        return path
    }
    
    private func drawEyes(in rect: CGRect, context: GraphicsContext) {
        let eyeSize = rect.width / 5
        
        let leftEyeRect = CGRect(
            x: rect.midX - rect.width / 4 - eyeSize / 2,
            y: rect.midY - rect.height / 6,
            width: eyeSize,
            height: eyeSize
        )
        
        let rightEyeRect = CGRect(
            x: rect.midX + rect.width / 4 - eyeSize / 2,
            y: rect.midY - rect.height / 6,
            width: eyeSize,
            height: eyeSize
        )
        
        // 眼白
        context.fill(Circle().path(in: leftEyeRect), with: .color(.white))
        context.fill(Circle().path(in: rightEyeRect), with: .color(.white))
        
        // 瞳孔
        let pupilSize = eyeSize / 2
        context.fill(Circle().path(in: CGRect(
            x: leftEyeRect.midX - pupilSize / 2,
            y: leftEyeRect.midY - pupilSize / 2,
            width: pupilSize,
            height: pupilSize
        )), with: .color(skin.eyeColor))
        
        context.fill(Circle().path(in: CGRect(
            x: rightEyeRect.midX - pupilSize / 2,
            y: rightEyeRect.midY - pupilSize / 2,
            width: pupilSize,
            height: pupilSize
        )), with: .color(skin.eyeColor))
    }
    
    private func drawBodyTexture(in rect: CGRect, context: GraphicsContext) {
        // 简化的纹理效果
        for i in 0..<2 {
            for j in 0..<2 {
                let scaleRect = CGRect(
                    x: rect.minX + CGFloat(i) * rect.width / 2,
                    y: rect.minY + CGFloat(j) * rect.height / 2,
                    width: rect.width / 2,
                    height: rect.height / 2
                )
                
                let scalePath = Ellipse().path(in: scaleRect)
                context.stroke(scalePath, with: .color(.white.opacity(skin.textureOpacity)), lineWidth: 0.5)
            }
        }
    }
    
    private func interpolateColor(from start: Color, to end: Color, progress: CGFloat) -> Color {
        return progress < 0.5 ? start : end
    }
}
