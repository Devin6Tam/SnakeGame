import SwiftUI
import ViewModel
import Common

/// 蛇渲染器 - 负责绘制更生动的蛇
@MainActor
public struct SnakeRenderer: View {
    @ObservedObject var viewModel: SnakeGameViewModel
    @State private var blinkState = false
    @State private var swingOffset: CGFloat = 0
    @State private var mouthState = false
    
    private let gridWidth: Int
    private let gridHeight: Int
    private let gridSize: CGFloat
    
    public init(viewModel: SnakeGameViewModel, gridSize: CGFloat) {
        self.viewModel = viewModel
        self.gridWidth = GameConfig.gridWidth
        self.gridHeight = GameConfig.gridHeight
        self.gridSize = gridSize
    }
    
    public var body: some View {
        Canvas { context, size in
            let cellWidth = size.width / CGFloat(gridWidth)
            let cellHeight = size.height / CGFloat(gridHeight)
            
            // 绘制食物
            if let food = viewModel.food {
                drawFood(at: food, in: context, cellWidth: cellWidth, cellHeight: cellHeight)
            }
            
            // 绘制蛇
            drawSnake(in: context, cellWidth: cellWidth, cellHeight: cellHeight)
        }
        .frame(width: gridSize, height: gridSize)
        .onAppear {
            startAnimations()
        }
    }
    
    // MARK: - 绘制方法
    
    /// 绘制食物
    private func drawFood(at point: Point, in context: GraphicsContext, cellWidth: CGFloat, cellHeight: CGFloat) {
        let foodRect = CGRect(
            x: CGFloat(point.x) * cellWidth,
            y: CGFloat(point.y) * cellHeight,
            width: cellWidth,
            height: cellHeight
        )
        
        // 基础食物形状
        let foodPath = Circle().path(in: foodRect.insetBy(dx: 3, dy: 3))
        
        // 渐变效果
        let gradient = Gradient(colors: [
            viewModel.currentSkin.bodyColor,
            viewModel.currentSkin.headColor
        ])
        
        context.fill(foodPath, with: .radialGradient(
            gradient,
            center: CGPoint(x: foodRect.midX, y: foodRect.midY),
            startRadius: 0,
            endRadius: cellWidth / 2
        ))
        
        // 高光效果
        let highlightRect = CGRect(
            x: foodRect.midX - cellWidth / 8,
            y: foodRect.midY - cellHeight / 8,
            width: cellWidth / 4,
            height: cellHeight / 4
        )
        
        let highlightPath = Circle().path(in: highlightRect)
        context.fill(highlightPath, with: .color(.white.opacity(0.6)))
    }
    
    /// 绘制蛇
    private func drawSnake(in context: GraphicsContext, cellWidth: CGFloat, cellHeight: CGFloat) {
        let snake = viewModel.snake
        guard !snake.isEmpty else { return }
        
        // 绘制蛇身（从尾部到头部，便于渐变效果）
        for (index, point) in snake.enumerated().reversed() {
            let isHead = index == 0
            
            if isHead {
                drawSnakeHead(at: point, in: context, cellWidth: cellWidth, cellHeight: cellHeight)
            } else {
                drawSnakeBody(at: point, index: index, in: context, cellWidth: cellWidth, cellHeight: cellHeight)
            }
        }
    }
    
    /// 绘制蛇头
    private func drawSnakeHead(at point: Point, in context: GraphicsContext, cellWidth: CGFloat, cellHeight: CGFloat) {
        let rect = CGRect(
            x: CGFloat(point.x) * cellWidth,
            y: CGFloat(point.y) * cellHeight,
            width: cellWidth,
            height: cellHeight
        )
        
        // 蛇头基础形状
        let headPath = createSnakeHeadPath(in: rect)
        
        // 头部渐变效果
        let headGradient = Gradient(colors: [
            viewModel.currentSkin.headColor,
            viewModel.currentSkin.headColor.opacity(0.8),
            viewModel.currentSkin.bodyColor
        ])
        
        context.fill(headPath, with: .radialGradient(
            headGradient,
            center: CGPoint(x: rect.midX, y: rect.midY),
            startRadius: 0,
            endRadius: cellWidth
        ))
        
        // 头部轮廓
        context.stroke(headPath, with: .color(viewModel.currentSkin.headColor.opacity(0.6)), lineWidth: 1.5)
        
        // 绘制眼睛和嘴巴
        drawSnakeFace(in: rect, context: context, cellWidth: cellWidth, cellHeight: cellHeight)
        
        // 纹理效果
        if viewModel.currentSkin.hasTexture {
            drawHeadTexture(in: rect, context: context)
        }
    }
    
    /// 创建蛇头路径（更自然的形状）
    private func createSnakeHeadPath(in rect: CGRect) -> Path {
        var path = Path()
        
        let radius = min(rect.width, rect.height) / 2 - 2
        let center = CGPoint(x: rect.midX, y: rect.midY)
        
        // 创建椭圆形头部
        path.addEllipse(in: CGRect(
            x: center.x - radius,
            y: center.y - radius * 0.7,
            width: radius * 2,
            height: radius * 1.4
        ))
        
        return path
    }
    
    /// 绘制蛇脸（眼睛、嘴巴）
    private func drawSnakeFace(in rect: CGRect, context: GraphicsContext, cellWidth: CGFloat, cellHeight: CGFloat) {
        let direction = viewModel.currentDirection
        
        // 眼睛位置（根据方向调整）
        let eyeSize = cellWidth / 5
        let eyeYOffset = cellHeight / 6
        
        let leftEyeRect: CGRect
        let rightEyeRect: CGRect
        
        switch direction {
        case .up, .down:
            leftEyeRect = CGRect(
                x: rect.midX - cellWidth / 3 - eyeSize / 2,
                y: rect.midY - eyeYOffset,
                width: eyeSize,
                height: eyeSize
            )
            rightEyeRect = CGRect(
                x: rect.midX + cellWidth / 3 - eyeSize / 2,
                y: rect.midY - eyeYOffset,
                width: eyeSize,
                height: eyeSize
            )
        case .left, .right:
            leftEyeRect = CGRect(
                x: rect.midX - eyeSize / 2,
                y: rect.midY - cellHeight / 4,
                width: eyeSize,
                height: eyeSize
            )
            rightEyeRect = CGRect(
                x: rect.midX - eyeSize / 2,
                y: rect.midY + cellHeight / 4 - eyeSize,
                width: eyeSize,
                height: eyeSize
            )
        }
        
        // 绘制眼睛（支持眨眼动画）
        if !blinkState || !viewModel.currentSkin.hasEyesBlink {
            drawEye(in: leftEyeRect, context: context)
            drawEye(in: rightEyeRect, context: context)
        }
        
        // 绘制嘴巴
        drawMouth(in: rect, context: context, direction: direction, cellWidth: cellWidth, cellHeight: cellHeight)
    }
    
    /// 绘制眼睛
    private func drawEye(in rect: CGRect, context: GraphicsContext) {
        // 眼白
        let eyeWhitePath = Circle().path(in: rect)
        context.fill(eyeWhitePath, with: .color(.white))
        
        // 瞳孔
        let pupilRect = CGRect(
            x: rect.midX - rect.width / 4,
            y: rect.midY - rect.height / 4,
            width: rect.width / 2,
            height: rect.height / 2
        )
        
        let pupilPath = Circle().path(in: pupilRect)
        context.fill(pupilPath, with: .color(viewModel.currentSkin.eyeColor))
        
        // 高光
        let highlightRect = CGRect(
            x: pupilRect.midX - pupilRect.width / 6,
            y: pupilRect.midY - pupilRect.height / 6,
            width: pupilRect.width / 3,
            height: pupilRect.height / 3
        )
        
        let highlightPath = Circle().path(in: highlightRect)
        context.fill(highlightPath, with: .color(.white.opacity(0.8)))
    }
    
    /// 绘制嘴巴
    private func drawMouth(in rect: CGRect, context: GraphicsContext, direction: Direction, cellWidth: CGFloat, cellHeight: CGFloat) {
        let mouthWidth = cellWidth / 3
        let mouthHeight = cellHeight / 8
        
        let mouthRect: CGRect
        
        switch direction {
        case .up:
            mouthRect = CGRect(
                x: rect.midX - mouthWidth / 2,
                y: rect.maxY - mouthHeight - 2,
                width: mouthWidth,
                height: mouthHeight
            )
        case .down:
            mouthRect = CGRect(
                x: rect.midX - mouthWidth / 2,
                y: rect.minY + 2,
                width: mouthWidth,
                height: mouthHeight
            )
        case .left:
            mouthRect = CGRect(
                x: rect.maxX - mouthHeight - 2,
                y: rect.midY - mouthWidth / 2,
                width: mouthHeight,
                height: mouthWidth
            )
        case .right:
            mouthRect = CGRect(
                x: rect.minX + 2,
                y: rect.midY - mouthWidth / 2,
                width: mouthHeight,
                height: mouthWidth
            )
        }
        
        let mouthPath = RoundedRectangle(cornerRadius: 2).path(in: mouthRect)
        context.fill(mouthPath, with: .color(.black.opacity(0.6)))
    }
    
    /// 绘制蛇身
    private func drawSnakeBody(at point: Point, index: Int, in context: GraphicsContext, cellWidth: CGFloat, cellHeight: CGFloat) {
        let rect = CGRect(
            x: CGFloat(point.x) * cellWidth,
            y: CGFloat(point.y) * cellHeight,
            width: cellWidth,
            height: cellHeight
        )
        
        // 计算摆动偏移
        let swing = calculateSwingOffset(for: index)
        let adjustedRect = rect.offsetBy(dx: swing, dy: 0)
        
        // 身体渐变效果（从头部到尾部）
        let progress = CGFloat(index) / CGFloat(viewModel.snake.count - 1)
        let bodyColor = interpolateColor(
            from: viewModel.currentSkin.headColor,
            to: viewModel.currentSkin.bodyColor,
            progress: progress
        )
        
        let bodyPath = createSnakeBodyPath(in: adjustedRect, index: index)
        
        // 身体填充
        context.fill(bodyPath, with: .color(bodyColor))
        
        // 身体轮廓
        context.stroke(bodyPath, with: .color(bodyColor.opacity(0.6)), lineWidth: 1)
        
        // 纹理效果
        if viewModel.currentSkin.hasTexture {
            drawBodyTexture(in: adjustedRect, context: context, progress: progress)
        }
    }
    
    /// 创建蛇身路径（更自然的连接）
    private func createSnakeBodyPath(in rect: CGRect, index: Int) -> Path {
        var path = Path()
        
        let radius = min(rect.width, rect.height) / 2 - 1.5
        let center = CGPoint(x: rect.midX, y: rect.midY)
        
        // 椭圆形身体，更自然
        path.addEllipse(in: CGRect(
            x: center.x - radius,
            y: center.y - radius * 0.8,
            width: radius * 2,
            height: radius * 1.6
        ))
        
        return path
    }
    
    /// 计算摆动偏移
    private func calculateSwingOffset(for index: Int) -> CGFloat {
        guard viewModel.currentSkin.bodySwing else { return 0 }
        
        let swingIntensity = viewModel.currentSkin.swingIntensity
        let phase = Double(index) * 0.3 + swingOffset
        return sin(phase) * swingIntensity
    }
    
    /// 绘制头部纹理
    private func drawHeadTexture(in rect: CGRect, context: GraphicsContext) {
        let scale = viewModel.currentSkin.textureScale
        let opacity = viewModel.currentSkin.textureOpacity
        
        // 简单的鳞片纹理
        for i in 0..<3 {
            for j in 0..<2 {
                let scaleRect = CGRect(
                    x: rect.minX + CGFloat(i) * rect.width / 3,
                    y: rect.minY + CGFloat(j) * rect.height / 2,
                    width: rect.width / 3 * scale,
                    height: rect.height / 2 * scale
                )
                
                let scalePath = Ellipse().path(in: scaleRect)
                context.stroke(scalePath, with: .color(.white.opacity(opacity)), lineWidth: 0.5)
            }
        }
    }
    
    /// 绘制身体纹理
    private func drawBodyTexture(in rect: CGRect, context: GraphicsContext, progress: CGFloat) {
        let scale = viewModel.currentSkin.textureScale
        let opacity = viewModel.currentSkin.textureOpacity * (1.0 - progress * 0.5)
        
        // 鳞片纹理
        for i in 0..<2 {
            for j in 0..<2 {
                let scaleRect = CGRect(
                    x: rect.minX + CGFloat(i) * rect.width / 2,
                    y: rect.minY + CGFloat(j) * rect.height / 2,
                    width: rect.width / 2 * scale,
                    height: rect.height / 2 * scale
                )
                
                let scalePath = Ellipse().path(in: scaleRect)
                context.stroke(scalePath, with: .color(.white.opacity(opacity)), lineWidth: 0.3)
            }
        }
    }
    
    // MARK: - 工具方法
    
    /// 颜色插值
    private func interpolateColor(from start: Color, to end: Color, progress: CGFloat) -> Color {
        // 简化的颜色插值
        return progress < 0.5 ? start : end
    }
    
    /// 启动动画 - 使用定时器更新状态
    private func startAnimations() {
        // 眨眼动画 - 使用简单定时器
        if viewModel.currentSkin.hasEyesBlink {
            // 创建一个定时器来触发眨眼
            Timer.scheduledTimer(withTimeInterval: viewModel.currentSkin.blinkInterval, repeats: true) { @Sendable [self] _ in
                self.blinkState = true
                // 延迟恢复
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    self.blinkState = false
                }
            }
        }
        
        // 摆动动画 - 使用简单定时器
        if viewModel.currentSkin.bodySwing {
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { @Sendable [self] _ in
                self.swingOffset += 0.3
            }
        }
    }
}
