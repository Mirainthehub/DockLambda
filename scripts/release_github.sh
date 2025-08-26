#!/bin/bash
#
# DockLambda GitHub Release 发布脚本
# 功能：将打包好的 ZIP 上传到 GitHub Releases
# 依赖：GitHub CLI (gh) 且已登录
#

set -e

# ==================== 配置变量 ====================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ZIP_NAME="DockLambda-macOS.zip"
ZIP_PATH="$PROJECT_ROOT/build/ReleaseUnsigned/$ZIP_NAME"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ==================== 工具函数 ====================

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

show_usage() {
    echo "用法："
    echo "  $0 <TAG> [TITLE] [NOTES_FILE]"
    echo ""
    echo "参数："
    echo "  TAG        - Release 标签 (例如: v1.0.0)"
    echo "  TITLE      - Release 标题 (可选，默认使用 TAG)"
    echo "  NOTES_FILE - 更新说明文件路径 (可选)"
    echo ""
    echo "示例："
    echo "  $0 v1.0.0"
    echo "  $0 v1.0.0 \"DockLambda v1.0.0\""
    echo "  $0 v1.0.0 \"DockLambda v1.0.0\" CHANGELOG.md"
    echo ""
    echo "前置条件："
    echo "  1. 已运行 ./scripts/package_unsigned.sh 生成 ZIP"
    echo "  2. 已安装并登录 GitHub CLI: gh auth login"
}

check_prerequisites() {
    log_info "检查前置条件..."
    
    # 检查 GitHub CLI
    if ! command -v gh &> /dev/null; then
        log_error "GitHub CLI (gh) 未安装"
        echo "   安装方法："
        echo "   brew install gh"
        echo "   # 或访问 https://cli.github.com/"
        exit 1
    fi
    
    # 检查登录状态
    if ! gh auth status &> /dev/null; then
        log_error "GitHub CLI 未登录"
        echo "   请先登录："
        echo "   gh auth login"
        exit 1
    fi
    
    # 检查是否在 Git 仓库中
    if ! git rev-parse --git-dir &> /dev/null; then
        log_error "当前目录不是 Git 仓库"
        exit 1
    fi
    
    # 检查 ZIP 文件
    if [ ! -f "$ZIP_PATH" ]; then
        log_error "未找到 ZIP 文件: $ZIP_PATH"
        echo "   请先运行打包脚本："
        echo "   ./scripts/package_unsigned.sh"
        echo "   # 或"
        echo "   make package"
        exit 1
    fi
    
    log_success "前置条件检查通过"
}

get_repo_info() {
    # 获取仓库信息
    REPO_OWNER=$(gh repo view --json owner --jq .owner.login)
    REPO_NAME=$(gh repo view --json name --jq .name)
    
    if [ -z "$REPO_OWNER" ] || [ -z "$REPO_NAME" ]; then
        log_error "无法获取仓库信息，请确保在正确的 Git 仓库中运行"
        exit 1
    fi
    
    log_info "仓库: $REPO_OWNER/$REPO_NAME"
}

create_or_update_release() {
    local tag="$1"
    local title="$2"
    local notes_file="$3"
    
    log_info "处理 Release: $tag"
    
    # 检查 Release 是否已存在
    if gh release view "$tag" &> /dev/null; then
        log_warning "Release $tag 已存在，将更新资产文件"
        
        # 上传资产（覆盖已存在的）
        gh release upload "$tag" "$ZIP_PATH" --clobber
        
        log_success "资产文件上传完成"
        
    else
        log_info "创建新的 Release: $tag"
        
        # 构建 gh release create 命令参数
        local create_args=("$tag" "$ZIP_PATH" --title "$title")
        
        # 添加说明文件（如果提供）
        if [ -n "$notes_file" ] && [ -f "$notes_file" ]; then
            create_args+=(--notes-file "$notes_file")
            log_info "使用说明文件: $notes_file"
        else
            # 生成默认说明
            local default_notes="🐾 DockLambda $tag

**未签名测试版本** - 仅用于测试和小范围分发

## 📥 安装说明

1. 下载 \`DockLambda-macOS.zip\`
2. 解压并拖入 \`/Applications\` 目录
3. 首次打开时右键选择"打开"绕过 Gatekeeper

## ⚠️ 重要提示

- 此为未签名/未公证版本
- 仅适用于测试环境
- 正式分发请使用 Developer ID 签名版本

## 🔧 系统要求

- macOS 13.0 或更高版本
- 支持 Intel 和 Apple Silicon Mac"

            create_args+=(--notes "$default_notes")
        fi
        
        # 创建 Release
        gh release create "${create_args[@]}"
        
        log_success "Release 创建完成"
    fi
}

show_results() {
    local tag="$1"
    
    # 获取 Release URL
    local release_url=$(gh release view "$tag" --json url --jq .url)
    local download_url="https://github.com/$REPO_OWNER/$REPO_NAME/releases/download/$tag/$ZIP_NAME"
    
    echo ""
    echo "🎉 发布完成！"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🔗 Release 页面: $release_url"
    echo "📥 下载链接: $download_url"
    echo ""
    echo "📋 分享给用户的安装说明："
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "# DockLambda $tag - macOS Dock 宠物"
    echo ""
    echo "## 📥 下载与安装"
    echo ""
    echo "1. **下载**: [DockLambda-macOS.zip]($download_url)"
    echo "2. **解压**: 双击 ZIP 文件解压"
    echo "3. **安装**: 将 \`DockLambda.app\` 拖入 \`/Applications\` 目录"
    echo "4. **首次运行**: 右键点击应用选择\"打开\"绕过 Gatekeeper"
    echo ""
    echo "## ⚠️ 注意事项"
    echo ""
    echo "- 此版本未签名，仅用于测试"
    echo "- 需要 macOS 13.0 或更高版本"
    echo "- 如遇到\"已损坏\"提示，请在终端运行："
    echo "  \`\`\`bash"
    echo "  xattr -cr /Applications/DockLambda.app"
    echo "  \`\`\`"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
}

# ==================== 主流程 ====================

main() {
    echo "🚀 DockLambda GitHub Release 发布脚本"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # 检查参数
    if [ $# -lt 1 ]; then
        log_error "缺少必需参数"
        echo ""
        show_usage
        exit 1
    fi
    
    local tag="$1"
    local title="${2:-$tag}"  # 默认标题为标签
    local notes_file="$3"
    
    # 验证标签格式（建议以 v 开头）
    if [[ ! "$tag" =~ ^v?[0-9]+\.[0-9]+\.[0-9]+.*$ ]]; then
        log_warning "标签格式建议：v1.0.0 或 1.0.0"
    fi
    
    # 执行发布流程
    check_prerequisites
    get_repo_info
    create_or_update_release "$tag" "$title" "$notes_file"
    show_results "$tag"
    
    log_success "发布流程完成！"
}

# 脚本入口
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi