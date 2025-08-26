# DockLambda Makefile
# 简化常用构建和发布命令

.PHONY: all clean package release help

# 默认目标
all: package

# 显示帮助信息
help:
	@echo "DockLambda 构建和发布命令："
	@echo ""
	@echo "  make package              - 编译并打包 DockLambda-macOS.zip"
	@echo "  make release TAG=v1.0.0   - 发布到 GitHub Releases"
	@echo "  make clean                - 清理构建目录"
	@echo "  make help                 - 显示此帮助信息"
	@echo ""
	@echo "示例："
	@echo "  make package"
	@echo "  make release TAG=v1.0.0"
	@echo "  make release TAG=v1.0.0 TITLE=\"DockLambda v1.0.0\" NOTES=CHANGELOG.md"
	@echo ""
	@echo "要求："
	@echo "  - Xcode 或 Xcode Command Line Tools"
	@echo "  - GitHub CLI (gh) - 仅发布时需要"

# 打包应用
package:
	@echo "🔨 开始打包 DockLambda..."
	@chmod +x scripts/package_unsigned.sh
	@./scripts/package_unsigned.sh

# 发布到 GitHub Releases
release:
	@if [ -z "$(TAG)" ]; then \
		echo "❌ 错误: 请指定 TAG 参数"; \
		echo "   示例: make release TAG=v1.0.0"; \
		exit 1; \
	fi
	@echo "🚀 发布到 GitHub Releases..."
	@chmod +x scripts/release_github.sh
	@./scripts/release_github.sh "$(TAG)" "$(TITLE)" "$(NOTES)"

# 清理构建目录
clean:
	@echo "🧹 清理构建目录..."
	@rm -rf build/
	@rm -rf DerivedData/
	@echo "✅ 清理完成"

# 验证工具链（内部使用）
check-tools:
	@echo "🔍 检查工具链..."
	@command -v xcodebuild >/dev/null 2>&1 || { echo "❌ xcodebuild 未找到"; exit 1; }
	@command -v zip >/dev/null 2>&1 || { echo "❌ zip 未找到"; exit 1; }
	@command -v gh >/dev/null 2>&1 || echo "⚠️  gh 未找到 (发布功能不可用)"
	@echo "✅ 工具链检查完成"

# 快速测试构建（不打包）
test-build:
	@echo "🧪 测试构建..."
	@xcodebuild -scheme DockLambda -configuration Release build -quiet
	@echo "✅ 测试构建成功"