import SwiftUI

/// 游戏配色方案
public struct ColorScheme {
    // MARK: - 主色调（柔和的莫兰迪色系）
    
    /// 蛇头颜色 - 柔和的薄荷绿
    public static let snakeHead = Color(red: 0.4, green: 0.8, blue: 0.6)
    
    /// 蛇身颜色 - 柔和的灰绿
    public static let snakeBody = Color(red: 0.5, green: 0.75, blue: 0.6)
    
    /// 食物颜色 - 柔和的珊瑚粉
    public static let food = Color(red: 0.95, green: 0.6, blue: 0.55)
    
    /// 网格背景颜色 - 浅灰
    public static let gridBackground = Color(red: 0.97, green: 0.97, blue: 0.97)
    
    /// 网格线颜色 - 浅灰
    public static let gridLine = Color(red: 0.85, green: 0.85, blue: 0.85)
    
    /// 应用背景色 - 米白
    public static let appBackground = Color(red: 0.98, green: 0.98, blue: 0.96)
    
    /// 按钮颜色
    public static let buttonPrimary = Color(red: 0.5, green: 0.7, blue: 0.9)
    public static let buttonSuccess = Color(red: 0.6, green: 0.8, blue: 0.6)
    public static let buttonWarning = Color(red: 0.9, green: 0.85, blue: 0.5)
    public static let buttonDanger = Color(red: 0.9, green: 0.7, blue: 0.7)
    public static let buttonRestart = Color(red: 0.95, green: 0.75, blue: 0.5)
    
    /// 文字颜色
    public static let textPrimary = Color(red: 0.2, green: 0.2, blue: 0.2)
    public static let textSecondary = Color(red: 0.5, green: 0.5, blue: 0.5)
    
    /// 状态颜色
    public static let statusPlaying = Color(red: 0.5, green: 0.8, blue: 0.6)
    public static let statusPaused = Color(red: 0.95, green: 0.85, blue: 0.5)
    public static let statusGameOver = Color(red: 0.9, green: 0.6, blue: 0.55)
    public static let statusNotStarted = Color(red: 0.6, green: 0.6, blue: 0.6)
    
    /// 说明卡片背景
    public static let cardBackground = Color(red: 0.95, green: 0.95, blue: 0.93)
    
    /// 蛇眼睛颜色 - 柔和的白色
    public static let snakeEye = Color(red: 0.98, green: 0.98, blue: 0.98)
    
    private init() {}
}
