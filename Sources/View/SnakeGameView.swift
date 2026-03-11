import SwiftUI
import AppKit
import Common
import Model
import ViewModel

/// 游戏主视图（View层）
public struct SnakeGameView: View {
    @StateObject private var viewModel = SnakeGameViewModel()
    @State private var gridSize: CGFloat = 300
    
    private let gridWidth = GameConfig.gridWidth
    private let gridHeight = GameConfig.gridHeight
    
    public init() {}
    
    public var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 20) {
                    // 游戏标题和分数
                    headerView
                        .padding(.top, 20)
                        .frame(maxWidth: .infinity)
                    
                    // 难度选择器
                    difficultySelector
                        .frame(maxWidth: .infinity)
                    
                    // 皮肤选择器
                    skinSelector
                        .frame(maxWidth: .infinity)
                    
                    // 游戏状态显示
                    gameStateView
                        .frame(height: 30)
                        .frame(maxWidth: .infinity)
                    
                    // 游戏网格 - 响应式大小
                    gameGridView
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                    
                    // 控制按钮
                    controlButtonsView
                        .frame(maxWidth: .infinity)
                    
                    // 方向控制按钮
                    directionControlButtonsView
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                    
                    // 游戏说明
                    instructionsView
                        .frame(maxWidth: .infinity)
                    
                    Spacer()
                        .frame(height: 40)
                }
                .frame(maxWidth: min(600, geometry.size.width - 40))
                .frame(maxWidth: .infinity)
                .padding()
            }
            .onAppear {
                // 根据屏幕大小调整网格大小
                calculateGridSize(screenSize: geometry.size)
            }
            .onChange(of: geometry.size) { oldValue, newValue in
                calculateGridSize(screenSize: newValue)
            }
        }
        .background(ColorScheme.appBackground)
        .focusable()
        .onKeyPress(phases: [.down]) { press in
            handleKeyPress(press)
            return .handled
        }
    }
    
    // MARK: - 屏幕适配
    
    /// 计算网格大小
    private func calculateGridSize(screenSize: CGSize) {
        let minDimension = min(screenSize.width, screenSize.height)
        let availableWidth = screenSize.width - 40 // 减去padding
        
        // 根据屏幕宽度动态计算网格大小，最大不超过400，最小不小于200
        let calculatedSize = min(availableWidth * 0.85, minDimension * 0.6, 400)
        gridSize = max(calculatedSize, 200)
    }
    
    // MARK: - 子视图
    
    /// 游戏标题和分数视图
    private var headerView: some View {
        VStack(spacing: 10) {
            Text("贪吃蛇游戏")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(ColorScheme.snakeHead)
                .frame(maxWidth: .infinity, alignment: .center)
            
            HStack(spacing: 30) {
                Spacer()
                scoreView(title: "当前分数", value: viewModel.score, color: ColorScheme.buttonPrimary)
                Spacer()
                scoreView(title: "最高分", value: viewModel.highScore, color: ColorScheme.buttonWarning)
                Spacer()
            }
        }
        .frame(maxWidth: .infinity)
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
            
            Picker("难度", selection: $viewModel.difficulty) {
                ForEach(Difficulty.allCases, id: \.self) { difficulty in
                    Text(difficulty.rawValue).tag(difficulty)
                }
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 400)
            
            Text(viewModel.difficulty.description)
                .font(.caption)
                .foregroundColor(ColorScheme.textSecondary)
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity)
    }
    
    /// 游戏状态视图
    private var gameStateView: some View {
        Group {
            switch viewModel.gameState {
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
        .frame(maxWidth: .infinity, alignment: .center)
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
            
            ZStack {
                // 蛇和食物（使用新的渲染器）
                SnakeRenderer(viewModel: viewModel, gridSize: gridSize)
                
                // 特效层
                SnakeEffectsRenderer(effectsManager: viewModel.effectsManager, gridSize: gridSize)
            }
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
    
    /// 皮肤选择器
    private var skinSelector: some View {
        VStack(spacing: 12) {
            Text("蛇皮肤")
                .font(.headline)
                .foregroundColor(ColorScheme.textSecondary)
            
            // 根据屏幕宽度动态调整皮肤预览大小
            GeometryReader { geometry in
                let previewSize = min(80, (geometry.size.width - 60) / 4)
                
                // 皮肤预览网格 - 响应式且居中
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: max(8, min(16, (geometry.size.width - 80) / 10))) {
                        ForEach(viewModel.availableSkins, id: \.name) { skin in
                            Button(action: { viewModel.changeSkin(skin) }) {
                                SkinPreview(
                                    skin: skin,
                                    isSelected: viewModel.currentSkin.name == skin.name,
                                    size: previewSize
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 8)
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 90)
            
            // 当前皮肤描述
            VStack(spacing: 4) {
                Text(viewModel.currentSkin.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(ColorScheme.textPrimary)
                
                Text(viewModel.currentSkin.description)
                    .font(.caption)
                    .foregroundColor(ColorScheme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity)
    }
    
    /// 控制按钮视图
    private var controlButtonsView: some View {
        VStack(spacing: 15) {
            HStack(spacing: 20) {
                Spacer()
                mainActionButton()
                restartButton()
                Spacer()
            }
            
            // 方向控制提示
            Text("使用方向键或WASD控制移动")
                .font(.caption)
                .foregroundColor(ColorScheme.textSecondary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .frame(maxWidth: .infinity)
    }
    
    /// 主操作按钮
    private func mainActionButton(width: CGFloat = 160, height: CGFloat = 44) -> some View {
        Button(action: handleMainAction) {
            HStack(spacing: 8) {
                Image(systemName: buttonIcon)
                    .font(.system(size: 18))
                Text(buttonText)
                    .font(.system(size: 16))
            }
            .foregroundColor(.white)
            .frame(width: width, height: height)
            .background(buttonColor)
            .cornerRadius(12)
            .shadow(color: buttonColor.opacity(0.3), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
    
    /// 重新开始按钮
    private func restartButton(width: CGFloat = 160, height: CGFloat = 44) -> some View {
        Button(action: { viewModel.restartGame() }) {
            HStack(spacing: 8) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 18))
                Text("重新开始")
                    .font(.system(size: 16))
            }
            .foregroundColor(.white)
            .frame(width: width, height: height)
            .background(ColorScheme.buttonRestart)
            .cornerRadius(12)
            .shadow(color: ColorScheme.buttonRestart.opacity(0.3), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
    
    /// 方向控制按钮视图
    private var directionControlButtonsView: some View {
        VStack(spacing: 10) {
            Spacer()
            directionButton(direction: .up, icon: "arrow.up")
            Spacer()
            
            HStack(spacing: 10) {
                Spacer()
                directionButton(direction: .left, icon: "arrow.left")
                Spacer()
                    .frame(width: 80)
                directionButton(direction: .right, icon: "arrow.right")
                Spacer()
            }
            Spacer()
            
            directionButton(direction: .down, icon: "arrow.down")
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    /// 方向按钮
    private func directionButton(direction: Direction, icon: String, size: CGFloat = 60) -> some View {
        Button(action: { viewModel.changeDirection(direction) }) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(.white)
                .frame(width: size, height: size)
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
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("• 使用方向键或WASD控制蛇的移动")
            Text("• 吃到食物可以增加分数")
            Text("• 避免撞到墙壁或自己的身体")
            Text("• 暂停后可以继续游戏")
            Text("• 不同难度有不同的游戏速度")
        }
        .font(.caption)
        .foregroundColor(ColorScheme.textSecondary.opacity(0.9))
        .padding()
        .background(ColorScheme.cardBackground)
        .cornerRadius(12)
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - 计算属性
    
    /// 按钮文本
    private var buttonText: String {
        switch viewModel.gameState {
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
        switch viewModel.gameState {
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
        switch viewModel.gameState {
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
        switch viewModel.gameState {
        case .notStarted, .gameOver:
            viewModel.startGame()
        case .playing:
            viewModel.pauseGame()
        case .paused:
            viewModel.resumeGame()
        }
    }
    
    /// 处理键盘按键
    private func handleKeyPress(_ press: KeyPress) {
        guard viewModel.gameState == .playing || viewModel.gameState == .paused else { return }
        
        switch press.key {
        case .upArrow:
            viewModel.changeDirection(.up)
        case .downArrow:
            viewModel.changeDirection(.down)
        case .leftArrow:
            viewModel.changeDirection(.left)
        case .rightArrow:
            viewModel.changeDirection(.right)
        case "w":
            viewModel.changeDirection(.up)
        case "s":
            viewModel.changeDirection(.down)
        case "a":
            viewModel.changeDirection(.left)
        case "d":
            viewModel.changeDirection(.right)
        case " ":
            if viewModel.gameState == .playing {
                viewModel.pauseGame()
            } else if viewModel.gameState == .paused {
                viewModel.resumeGame()
            }
        case .return:
            if viewModel.gameState == .notStarted || viewModel.gameState == .gameOver {
                viewModel.startGame()
            }
        default:
            break
        }
    }
}
