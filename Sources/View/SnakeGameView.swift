import SwiftUI
import AppKit
import Common
import Model

/// 游戏主视图（View层）
public struct SnakeGameView: View {
    @StateObject private var game = SnakeGameModel()
    @State private var gridSize: CGFloat = 300
    
    private let gridWidth = GameConfig.gridWidth
    private let gridHeight = GameConfig.gridHeight
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 20) {
            // 游戏标题和分数
            headerView
                .padding(.top, 20)
            
            // 难度选择器
            difficultySelector
            
            // 游戏状态显示
            gameStateView
                .frame(height: 30)
            
            // 游戏网格
            gameGridView
                .padding(.vertical, 10)
            
            // 控制按钮
            controlButtonsView
            
            // 方向控制按钮
            directionControlButtonsView
                .padding(.vertical, 10)
            
            // 游戏说明
            instructionsView
                .padding(.horizontal)
            
            Spacer()
        }
        .padding()
        .background(ColorScheme.appBackground)
        .focusable()
        .onKeyPress(phases: [.down]) { press in
            handleKeyPress(press)
            return .handled
        }
    }
    
    // MARK: - 子视图
    
    /// 游戏标题和分数视图
    private var headerView: some View {
        VStack(spacing: 10) {
            Text("贪吃蛇游戏")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(ColorScheme.snakeHead)
            
            HStack(spacing: 30) {
                scoreView(title: "当前分数", value: game.score, color: ColorScheme.buttonPrimary)
                scoreView(title: "最高分", value: game.highScore, color: ColorScheme.buttonWarning)
            }
        }
    }
    
    /// 分数视图
    private func scoreView(title: String, value: Int, color: Color) -> some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundColor(ColorScheme.textSecondary)
            Text("\(value)")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
    }
    
    /// 难度选择器
    private var difficultySelector: some View {
        VStack(spacing: 8) {
            Text("难度等级")
                .font(.headline)
                .foregroundColor(ColorScheme.textSecondary)
            
            Picker("难度", selection: $game.difficulty) {
                ForEach(Difficulty.allCases, id: \.self) { difficulty in
                    Text(difficulty.rawValue).tag(difficulty)
                }
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 400)
            
            Text(game.difficulty.description)
                .font(.caption)
                .foregroundColor(ColorScheme.textSecondary)
        }
        .padding(.horizontal)
    }
    
    /// 游戏状态视图
    private var gameStateView: some View {
        Group {
            switch game.gameState {
            case .notStarted:
                statusText("游戏未开始", color: ColorScheme.statusNotStarted)
            case .playing:
                statusText("游戏中...", color: ColorScheme.statusPlaying)
            case .paused:
                statusText("游戏暂停", color: ColorScheme.statusPaused)
            case .gameOver:
                statusText("游戏结束!", color: ColorScheme.statusGameOver)
            }
        }
    }
    
    /// 状态文本
    private func statusText(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.headline)
            .foregroundColor(color)
    }
    
    /// 游戏网格视图
    private var gameGridView: some View {
        ZStack {
            // 网格背景
            gridBackground
            
            // 网格线
            gridLines
            
            // 蛇和食物
            snakeAndFoodView
        }
    }
    
    /// 网格背景
    private var gridBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(ColorScheme.gridBackground)
            .frame(width: gridSize, height: gridSize)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(ColorScheme.gridLine.opacity(0.5), lineWidth: 1)
            )
    }
    
    /// 网格线
    private var gridLines: some View {
        GeometryReader { geometry in
            let cellWidth = geometry.size.width / CGFloat(gridWidth)
            let cellHeight = geometry.size.height / CGFloat(gridHeight)
            
            // 垂直线
            ForEach(0..<gridWidth, id: \.self) { i in
                Path { path in
                    let x = CGFloat(i) * cellWidth
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: geometry.size.height))
                }
                .stroke(ColorScheme.gridLine.opacity(0.3), lineWidth: 0.5)
            }
            
            // 水平线
            ForEach(0..<gridHeight, id: \.self) { i in
                Path { path in
                    let y = CGFloat(i) * cellHeight
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                }
                .stroke(ColorScheme.gridLine.opacity(0.3), lineWidth: 0.5)
            }
        }
        .frame(width: gridSize, height: gridSize)
    }
    
    /// 蛇和食物视图
    private var snakeAndFoodView: some View {
        Canvas { context, size in
            let cellWidth = size.width / CGFloat(gridWidth)
            let cellHeight = size.height / CGFloat(gridHeight)
            
            // 绘制食物
            if let food = game.food {
                drawFood(at: food, in: context, cellWidth: cellWidth, cellHeight: cellHeight)
            }
            
            // 绘制蛇
            for (index, point) in game.snake.enumerated() {
                if index == 0 {
                    drawSnakeHead(at: point, in: context, cellWidth: cellWidth, cellHeight: cellHeight)
                } else {
                    drawSnakeBody(at: point, in: context, cellWidth: cellWidth, cellHeight: cellHeight)
                }
            }
        }
        .frame(width: gridSize, height: gridSize)
    }
    
    /// 绘制食物
    private func drawFood(at point: Point, in context: GraphicsContext, cellWidth: CGFloat, cellHeight: CGFloat) {
        let foodRect = CGRect(
            x: CGFloat(point.x) * cellWidth,
            y: CGFloat(point.y) * cellHeight,
            width: cellWidth,
            height: cellHeight
        )
        
        let foodPath = Circle().path(in: foodRect.insetBy(dx: 3, dy: 3))
        context.fill(foodPath, with: .color(ColorScheme.food))
        context.stroke(foodPath, with: .color(ColorScheme.food.opacity(0.6)), lineWidth: 1.5)
    }
    
    /// 绘制蛇头
    private func drawSnakeHead(at point: Point, in context: GraphicsContext, cellWidth: CGFloat, cellHeight: CGFloat) {
        let rect = CGRect(
            x: CGFloat(point.x) * cellWidth,
            y: CGFloat(point.y) * cellHeight,
            width: cellWidth,
            height: cellHeight
        )
        
        let headPath = RoundedRectangle(cornerRadius: 5).path(in: rect.insetBy(dx: 1.5, dy: 1.5))
        context.fill(headPath, with: .color(ColorScheme.snakeHead))
        context.stroke(headPath, with: .color(ColorScheme.snakeHead.opacity(0.7)), lineWidth: 1)
        
        // 眼睛
        drawEyes(in: rect, context: context, cellWidth: cellWidth, cellHeight: cellHeight)
    }
    
    /// 绘制蛇头眼睛
    private func drawEyes(in rect: CGRect, context: GraphicsContext, cellWidth: CGFloat, cellHeight: CGFloat) {
        let eyeSize = cellWidth / 4
        
        let leftEyeRect = CGRect(
            x: rect.minX + cellWidth / 4,
            y: rect.minY + cellHeight / 4,
            width: eyeSize,
            height: eyeSize
        )
        let rightEyeRect = CGRect(
            x: rect.maxX - cellWidth / 4 - eyeSize,
            y: rect.minY + cellHeight / 4,
            width: eyeSize,
            height: eyeSize
        )
        
        context.fill(Circle().path(in: leftEyeRect), with: .color(ColorScheme.snakeEye))
        context.fill(Circle().path(in: rightEyeRect), with: .color(ColorScheme.snakeEye))
    }
    
    /// 绘制蛇身
    private func drawSnakeBody(at point: Point, in context: GraphicsContext, cellWidth: CGFloat, cellHeight: CGFloat) {
        let rect = CGRect(
            x: CGFloat(point.x) * cellWidth,
            y: CGFloat(point.y) * cellHeight,
            width: cellWidth,
            height: cellHeight
        )
        
        let bodyPath = RoundedRectangle(cornerRadius: 4).path(in: rect.insetBy(dx: 1.5, dy: 1.5))
        context.fill(bodyPath, with: .color(ColorScheme.snakeBody))
        context.stroke(bodyPath, with: .color(ColorScheme.snakeBody.opacity(0.6)), lineWidth: 1)
    }
    
    /// 控制按钮视图
    private var controlButtonsView: some View {
        VStack(spacing: 15) {
            HStack(spacing: 20) {
                mainActionButton
                restartButton
            }
            
            // 方向控制提示
            Text("使用方向键或WASD控制移动")
                .font(.caption)
                .foregroundColor(ColorScheme.textSecondary)
        }
    }
    
    /// 主操作按钮
    private var mainActionButton: some View {
        Button(action: handleMainAction) {
            HStack {
                Image(systemName: buttonIcon)
                Text(buttonText)
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(buttonColor)
            .cornerRadius(12)
            .shadow(color: buttonColor.opacity(0.3), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
    
    /// 重新开始按钮
    private var restartButton: some View {
        Button(action: { game.restartGame() }) {
            HStack {
                Image(systemName: "arrow.clockwise")
                Text("重新开始")
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(ColorScheme.buttonRestart)
            .cornerRadius(12)
            .shadow(color: ColorScheme.buttonRestart.opacity(0.3), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
    
    /// 方向控制按钮视图
    private var directionControlButtonsView: some View {
        VStack(spacing: 10) {
            directionButton(direction: .up, icon: "arrow.up")
            
            HStack(spacing: 10) {
                directionButton(direction: .left, icon: "arrow.left")
                Spacer().frame(width: 80)
                directionButton(direction: .right, icon: "arrow.right")
            }
            
            directionButton(direction: .down, icon: "arrow.down")
        }
    }
    
    /// 方向按钮
    private func directionButton(direction: Direction, icon: String) -> some View {
        Button(action: { game.changeDirection(direction) }) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(ColorScheme.buttonPrimary)
                .cornerRadius(12)
                .shadow(color: ColorScheme.buttonPrimary.opacity(0.3), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
    
    /// 游戏说明视图
    private var instructionsView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("游戏说明:")
                .font(.headline)
                .foregroundColor(ColorScheme.textSecondary)
            
            Text("• 使用方向键控制蛇的移动")
            Text("• 吃到食物可以增加分数")
            Text("• 避免撞到墙壁或自己的身体")
            Text("• 暂停后可以继续游戏")
        }
        .font(.caption)
        .foregroundColor(ColorScheme.textSecondary.opacity(0.9))
        .padding()
        .background(ColorScheme.cardBackground)
        .cornerRadius(12)
    }
    
    // MARK: - 计算属性
    
    /// 按钮文本
    private var buttonText: String {
        switch game.gameState {
        case .notStarted, .gameOver:
            return "开始游戏"
        case .playing:
            return "暂停游戏"
        case .paused:
            return "继续游戏"
        }
    }
    
    /// 按钮图标
    private var buttonIcon: String {
        switch game.gameState {
        case .notStarted, .gameOver:
            return "play.fill"
        case .playing:
            return "pause.fill"
        case .paused:
            return "play.fill"
        }
    }
    
    /// 按钮颜色
    private var buttonColor: Color {
        switch game.gameState {
        case .notStarted, .gameOver:
            return ColorScheme.buttonSuccess
        case .playing:
            return ColorScheme.buttonWarning
        case .paused:
            return ColorScheme.buttonPrimary
        }
    }
    
    // MARK: - 事件处理
    
    /// 处理主按钮操作
    private func handleMainAction() {
        switch game.gameState {
        case .notStarted, .gameOver:
            game.startGame()
        case .playing:
            game.pauseGame()
        case .paused:
            game.resumeGame()
        }
    }
    
    /// 处理键盘按键
    private func handleKeyPress(_ press: KeyPress) {
        guard game.gameState == .playing || game.gameState == .paused else { return }
        
        switch press.key {
        case .upArrow:
            game.changeDirection(.up)
        case .downArrow:
            game.changeDirection(.down)
        case .leftArrow:
            game.changeDirection(.left)
        case .rightArrow:
            game.changeDirection(.right)
        case "w":
            game.changeDirection(.up)
        case "s":
            game.changeDirection(.down)
        case "a":
            game.changeDirection(.left)
        case "d":
            game.changeDirection(.right)
        case " ":
            if game.gameState == .playing {
                game.pauseGame()
            } else if game.gameState == .paused {
                game.resumeGame()
            }
        case .return:
            if game.gameState == .notStarted || game.gameState == .gameOver {
                game.startGame()
            }
        default:
            break
        }
    }
}
