# DockLambda 常见问题排查指南

## 🚨 紧急问题快速解决

### 问题：应用完全无法启动
**现象**: 双击图标没有反应，或闪现后消失

**快速诊断**:
```bash
# 检查崩溃日志
console | grep -i docklambda

# 手动启动并查看错误
./build/Build/Products/Debug/DockLambda.app/Contents/MacOS/DockLambda
```

**解决方案**:
1. **权限问题**: 右键应用 → "打开"，确认安全对话框
2. **macOS 版本**: 确认运行在 macOS 13.0+
3. **签名问题**: 重新编译或使用 `codesign --remove-signature DockLambda.app`
4. **依赖缺失**: 确认 Xcode 和系统框架完整

### 问题：宠物窗口不显示
**现象**: 应用启动成功，菜单栏有图标，但看不到宠物

**快速解决**:
```bash
# 重置窗口位置
defaults delete com.example.DockLambda relativeOffset
# 或通过菜单栏: λ → Reset Position
```

**其他方案**:
- 检查是否被隐藏: 菜单栏 → Show Pet
- 多屏环境: 检查其他显示器
- 透明度问题: 重启应用

## 🏗️ 编译构建问题

### Swift 编译错误

#### 错误: "Cannot find type 'SMAppService'"
**原因**: macOS 部署目标版本过低
**解决**:
```bash
# 项目设置中确认
MACOSX_DEPLOYMENT_TARGET = 13.0
```

#### 错误: SpriteKit 相关编译失败
**原因**: 框架链接问题
**解决**:
1. 项目设置 → Build Phases → Link Binary with Libraries
2. 确认包含: `SpriteKit.framework`, `AppKit.framework`
3. 如需要添加: "+" → SpriteKit.framework

#### 错误: Code signing 失败
**解决方案**:
```bash
# 方案1: 移除签名要求
CODE_SIGN_IDENTITY = ""
CODE_SIGN_STYLE = Manual

# 方案2: 使用开发者证书  
CODE_SIGN_STYLE = Automatic
DEVELOPMENT_TEAM = [Your Team ID]
```

### Xcode 项目配置

#### Info.plist 相关错误
**检查必需项**:
```xml
<key>LSUIElement</key>
<true/>
<key>LSMinimumSystemVersion</key>
<string>13.0</string>
<key>NSMainNibFile</key>
<string>MainMenu</string>  <!-- 或删除此行使用代码创建菜单 -->
```

#### Bundle Identifier 冲突
**解决**: 修改为唯一标识符
```
PRODUCT_BUNDLE_IDENTIFIER = com.yourname.docklambda
```

## 🎭 运行时功能问题

### 透明窗口和鼠标穿透

#### 问题：窗口不透明或有背景色
**检查代码**:
```swift
// PetWindow.swift 确认设置
window.isOpaque = false
window.backgroundColor = NSColor.clear
window.hasShadow = false
```

#### 问题：穿透模式不工作
**诊断步骤**:
1. 检查 UserDefaults: `defaults read com.example.DockLambda clickThrough`
2. 确认窗口属性: `window.ignoresMouseEvents`
3. 菜单状态同步: `StatusItemController.updateMenuItems()`

### Dock 定位和跟踪

#### 问题：宠物不跟随 Dock 移动
**排查步骤**:
```swift
// 手动测试 Dock 方向读取
let orientation = DockObserver.getDockOrientation()
print("Current dock orientation: \(orientation)")

// 检查偏好读取权限
let prefs = CFPreferencesCopyAppValue("orientation" as CFString, "com.apple.dock" as CFString)
print("Dock preferences: \(String(describing: prefs))")
```

**解决方案**:
1. **权限问题**: 应用可能无法读取系统偏好
2. **缓存延迟**: 增加轮询频率或添加强制刷新
3. **回退机制**: 使用屏幕可见区域计算 Dock 位置

#### 问题：多屏环境下定位错误
**临时解决**:
```swift
// 强制使用主屏
guard let screen = NSScreen.main else { return }

// 或遍历所有屏幕找 Dock
for screen in NSScreen.screens {
    let visibleFrame = screen.visibleFrame
    let screenFrame = screen.frame
    // 检查哪个屏幕的可见区域小于完整区域（有 Dock）
}
```

### SpriteKit 动画问题

#### 问题：动画卡顿或不流畅
**性能优化**:
```swift
// SKView 优化设置
skView.ignoresSiblingOrder = true
skView.shouldCullNonVisibleNodes = true
skView.preferredFramesPerSecond = 60

// SKScene 优化
scene.physicsWorld.speed = 0  // 如不需要物理引擎
```

#### 问题：占位符图像显示异常
**检查 SpriteLoader**:
```swift
// 确认占位符生成逻辑
private func createPlaceholderTexture(for state: PetState) -> SKTexture {
    let size = CGSize(width: 80, height: 80)
    // ... 确认图像创建成功
    return SKTexture(image: image)
}
```

## ⚙️ 系统集成问题

### CPU 使用率监控

#### 问题：CPU 读取失败或权限错误
**诊断代码**:
```swift
var cpuInfo = host_cpu_load_info()
var count = mach_msg_type_number_t(MemoryLayout<host_cpu_load_info>.size / MemoryLayout<integer_t>.size)

let result = withUnsafeMutablePointer(to: &cpuInfo) {
    $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
        host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, $0, &count)
    }
}

if result != KERN_SUCCESS {
    print("❌ CPU statistics failed with code: \(result)")
}
```

**解决方案**:
- 使用沙盒: 可能需要额外权限设置
- 回退方案: 生成合理的模拟 CPU 数据
- 监控频率: 降低查询频率避免系统负担

### Start at Login 问题

#### 问题：SMAppService 注册失败
**常见错误码**:
```swift
// 检查具体错误
do {
    try SMAppService.mainApp.register()
} catch let error as SMAppService.Error {
    switch error {
    case .bundleNotFound:
        print("开发环境下的正常现象")
    case .notAuthorized:
        print("需要用户在系统设置中手动批准")
    case .duplicateJob:
        print("已经注册，可以忽略")
    default:
        print("其他错误: \(error)")
    }
}
```

**解决步骤**:
1. **开发阶段**: Bundle 路径问题，打包后测试
2. **首次运行**: 引导用户到系统偏好设置批准
3. **权限检查**: 提供状态检查和用户指引

## 🐛 调试技巧和工具

### Console 日志分析
```bash
# 实时查看应用日志
log stream --process DockLambda --level debug

# 查看崩溃日志
log show --last 1d --predicate 'process == "DockLambda"'

# 系统启动项日志
log show --last 1d --predicate 'subsystem == "com.apple.ServiceManagement"'
```

### 性能分析
```bash
# CPU 使用情况
top -pid $(pgrep DockLambda) -s 5

# 内存泄漏检测
leaks DockLambda

# 文件句柄监控
lsof -p $(pgrep DockLambda)
```

### 开发调试
```swift
// 添加详细日志
#if DEBUG
print("🐛 Debug: \(message)")
#endif

// 断点和状态检查
override func mouseDown(with event: NSEvent) {
    print("🖱️ Mouse down at: \(event.locationInWindow)")
    print("🎭 Current state: \(petStateMachine.currentState)")
    super.mouseDown(with: event)
}
```

## 🔧 环境特定问题

### macOS Ventura 特殊问题

#### 隐私与安全增强
- **屏幕录制权限**: 某些 SpriteKit 功能可能需要权限
- **辅助功能权限**: 如需读取其他应用状态
- **文件访问权限**: 拖拽文件功能的沙盒限制

#### 解决方案:
```xml
<!-- Info.plist 添加使用说明 -->
<key>NSDesktopFolderUsageDescription</key>
<string>DockLambda需要访问拖拽到宠物上的文件</string>
```

### Apple Silicon Mac 特殊问题

#### Rosetta 2 兼容性
- 确保项目设置支持 arm64 架构
- 第三方库需要 Universal Binary

#### 性能优化
```swift
// 针对 M1/M2 优化
#if arch(arm64)
// ARM 特定优化
skView.preferredFramesPerSecond = 120  // ProMotion 支持
#endif
```

## 📞 获取帮助

### 社区资源
- **GitHub Issues**: 报告 bug 和功能请求
- **Apple 开发者论坛**: AppKit/SpriteKit 相关问题
- **Stack Overflow**: 标签 `swift`, `appkit`, `spritekit`

### 诊断信息收集
提交问题时请提供:
```bash
# 系统信息
sw_vers
uname -a

# 应用版本
defaults read com.example.DockLambda CFBundleVersion 2>/dev/null || echo "未安装"

# 相关日志
log show --last 1h --predicate 'process == "DockLambda"' --style compact
```

### 应急措施
如果应用出现严重问题:
```bash
# 完全重置应用状态
defaults delete com.example.DockLambda
rm -rf ~/Library/Caches/com.example.DockLambda
killall DockLambda

# 卸载登录项
launchctl unload ~/Library/LaunchAgents/com.example.DockLambda.plist 2>/dev/null
```

---

**💡 提示**: 大多数问题可以通过重启应用解决。如果问题持续存在，请按照上述步骤逐一排查，并收集相关日志信息以便进一步分析。