// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "SnakeGame",
    platforms: [
        .macOS(.v14) // 支持SwiftUI和KeyPress
    ],
    products: [
        .executable(
            name: "SnakeGame",
            targets: ["SnakeGame"]
        )
    ],
    dependencies: [
        // 这里可以添加外部依赖
    ],
    targets: [
        // MARK: - 主目标
        
        // 主可执行目标
        .executableTarget(
            name: "SnakeGame",
            dependencies: [
                "Common",
                "Model",
                "View",
                "Controller"
            ]
        ),
        
        // Common 模块：共享的数据结构和常量
        .target(
            name: "Common",
            path: "Sources/Common"
        ),
        
        // Model 模块：游戏逻辑和数据模型
        .target(
            name: "Model",
            dependencies: ["Common"],
            path: "Sources/Model"
        ),
        
        // View 模块：UI组件和视图
        .target(
            name: "View",
            dependencies: ["Common", "Model"],
            path: "Sources/View"
        ),
        
        // Controller 模块：控制器和应用入口
        .target(
            name: "Controller",
            dependencies: ["View"],
            path: "Sources/Controller"
        ),
        
        // MARK: - 测试目标
        
        // Common 模块测试
        .testTarget(
            name: "CommonTests",
            dependencies: ["Common"],
            path: "Tests/CommonTests"
        ),
        
        // Model 模块测试
        .testTarget(
            name: "ModelTests",
            dependencies: ["Model", "Common"],
            path: "Tests/ModelTests"
        ),
        
        // View 模块测试
        .testTarget(
            name: "ViewTests",
            dependencies: ["View", "Common"],
            path: "Tests/ViewTests"
        ),
        
        // Controller 模块测试
        .testTarget(
            name: "ControllerTests",
            dependencies: ["Controller"],
            path: "Tests/ControllerTests"
        )
    ]
)
