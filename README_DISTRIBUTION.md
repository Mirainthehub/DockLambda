# Simple Distribution (Unsigned, for Testing/Internal Use)

> ⚠️ **重要说明**: 以下为未签名/未公证的分发方案，仅适用于测试、内部使用或小范围分发。正式分发建议使用 Developer ID 签名和 Notarization。

## 📦 本地打包

### 快速开始

```bash
# 一键打包（推荐）
make package

# 或直接运行脚本
chmod +x scripts/package_unsigned.sh
./scripts/package_unsigned.sh
```

### 打包结果

- 📁 输出目录：`build/ReleaseUnsigned/`
- 📦 ZIP 文件：`DockLambda-macOS.zip`
- 🎯 包含内容：完整的 `DockLambda.app`

## 🚀 发布到 GitHub Releases

### 前置条件

```bash
# 安装 GitHub CLI
brew install gh

# 登录 GitHub
gh auth login
```

### 发布命令

```bash
# 基础发布
make release TAG=v1.0.0

# 自定义标题和说明
make release TAG=v1.0.0 TITLE="DockLambda v1.0.0 Beta" NOTES=CHANGELOG.md

# 或直接使用脚本
./scripts/release_github.sh v1.0.0
./scripts/release_github.sh v1.0.0 "DockLambda v1.0.0" CHANGELOG.md
```

### 发布流程

1. **检查前置条件** - GitHub CLI 登录状态和 ZIP 文件
2. **创建/更新 Release** - 自动处理已存在的标签
3. **上传资产文件** - 覆盖已存在的文件
4. **生成分享链接** - 提供下载 URL 和安装说明

## 👥 用户安装指引

### 下载和安装

1. **下载 ZIP**：从 GitHub Releases 下载 `DockLambda-macOS.zip`
2. **解压文件**：双击 ZIP 文件解压得到 `DockLambda.app`
3. **移动应用**：将 `DockLambda.app` 拖入 `/Applications` 目录
4. **首次启动**：按以下步骤绕过 Gatekeeper

### 绕过 Gatekeeper（未签名应用）

首次运行时系统可能提示"无法打开"、"来自未知开发者"或"应用已损坏"，请选择以下任一方式：

#### 方式 A：右键打开（推荐）
1. 右键点击 `DockLambda.app`
2. 选择"打开"
3. 在弹出对话框中再次点击"打开"
4. 成功运行后，后续可正常双击启动

#### 方式 B：系统设置
1. 尝试双击应用（会被阻止）
2. 打开"系统设置" → "隐私与安全性"
3. 在底部找到"DockLambda 已被阻止使用"
4. 点击"仍要打开"

#### 方式 C：命令行绕过
```bash
# 清除隔离属性
xattr -cr /Applications/DockLambda.app

# 然后正常双击启动
```

### 验证安装

安装成功后应看到：
- 🐾 透明宠物窗口出现在 Dock 附近
- λ 菜单栏图标（系统右上角）
- 可通过点击、拖拽与宠物互动

## 🔧 自动化构建 (GitHub Actions)

### 启用 CI 构建

项目包含 GitHub Actions 工作流（`.github/workflows/package-unsigned.yml`），可自动构建 ZIP 文件：

1. **触发方式**：
   - Push 到 `main` 分支
   - 创建 Release
   - 手动触发（workflow_dispatch）

2. **产物下载**：
   - 前往仓库 → Actions 页面
   - 选择最新的工作流运行
   - 下载 `DockLambda-macOS-unsigned` artifact

3. **手动发布到 Release**：
   ```bash
   # 下载 CI 产物后
   gh release create v1.0.0 DockLambda-macOS.zip --title "DockLambda v1.0.0"
   ```

### 工作流配置

工作流运行在 `macos-latest`，包含以下步骤：
- 检出代码
- 设置 Xcode 环境
- 运行打包脚本
- 上传构建产物

## ⚠️ 风险提示和限制

### 安全考虑

- **未签名风险**：系统无法验证应用来源和完整性
- **使用场景**：仅适用于可信来源的内部测试
- **分发范围**：不建议大规模公开分发

### 技术限制

- **Gatekeeper**：用户需手动绕过安全检查
- **更新机制**：无法使用自动更新（需 App Store 或签名）
- **权限申请**：某些系统权限可能受限
- **多屏支持**：仅支持主屏 Dock 跟随

### 系统要求

- **操作系统**：macOS 13.0 (Ventura) 或更高版本
- **架构支持**：Intel (x86_64) 和 Apple Silicon (arm64)
- **内存要求**：至少 100MB 可用内存
- **其他依赖**：无需额外安装其他软件

## 🎯 正式分发建议

如需正式分发，建议采用以下方案：

### Developer ID 分发
```bash
# 需要 Apple Developer 账号
codesign --deep --force --verify --verbose \
  --sign "Developer ID Application: Your Name" \
  DockLambda.app

# 公证
xcrun notarytool submit DockLambda.zip \
  --keychain-profile "notarytool-password"
```

### App Store 分发
- 完整的沙盒化改造
- 遵循 App Store 审核指南
- 使用 Mac App Store 证书签名

### 开源分发
- 提供源代码和构建说明
- 用户本地编译，自然信任
- 通过 Homebrew 等包管理器分发

---

**📚 相关文档**：
- [VERIFICATION_CHECKLIST.md](VERIFICATION_CHECKLIST.md) - 功能验收清单
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - 问题排查指南
- [README.md](README.md) - 项目主要文档