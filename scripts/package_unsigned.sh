#!/bin/bash
#
# DockLambda 未签名打包脚本
# 功能：编译 .app → 打包 .zip，用于测试和小范围分发
# 作者：DockLambda Release Engineering
#

set -e  # 任何命令失败时退出

# ==================== 配置变量 ====================

# 项目配置
SCHEME="DockLambda"
CONFIGURATION="Release"
APP_NAME="DockLambda.app"
BUNDLE_ID="com.example.DockLambda"
ZIP_NAME="DockLambda-macOS.zip"

# 路径配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ARCHIVE_PATH="$PROJECT_ROOT/build/DockLambda.xcarchive"
EXPORT_PATH="$PROJECT_ROOT/build/ReleaseUnsigned"
EXPORT_OPTIONS_PATH="$EXPORT_PATH/ExportOptions.plist"
ZIP_PATH="$EXPORT_PATH/$ZIP_NAME"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

check_command() {
    if ! command -v "$1" &> /dev/null; then
        log_error "$1 未安装或不在 PATH 中"
        echo "   解决方案："
        case "$1" in
            "xcodebuild")
                echo "   - 安装 Xcode 或 Xcode Command Line Tools"
                echo "   - 运行: xcode-select --install"
                ;;
            "zip")
                echo "   - zip 应该是系统自带，请检查 PATH"
                ;;
            "gh")
                echo "   - 安装 GitHub CLI: brew install gh"
                echo "   - 或访问: https://cli.github.com/"
                ;;
        esac
        return 1
    fi
    return 0
}

cleanup_build() {
    log_info "清理之前的构建产物..."
    rm -rf "$ARCHIVE_PATH"
    rm -rf "$EXPORT_PATH"
    mkdir -p "$EXPORT_PATH"
}

create_export_options() {
    log_info "生成 ExportOptions.plist..."
    cat > "$EXPORT_OPTIONS_PATH" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>developer-id</string>
    <key>signingStyle</key>
    <string>manual</string>
    <key>signingCertificate</key>
    <string></string>
    <key>teamID</key>
    <string></string>
    <key>destination</key>
    <string>export</string>
    <key>stripSwiftSymbols</key>
    <true/>
    <key>thinning</key>
    <string>&lt;none&gt;</string>
    <key>manageAppVersionAndBuildNumber</key>
    <false/>
    <key>compileBitcode</key>
    <false/>
</dict>
</plist>
EOF
}

build_archive() {
    log_info "开始构建 Archive..."
    log_info "Scheme: $SCHEME"
    log_info "Configuration: $CONFIGURATION"
    log_info "Archive Path: $ARCHIVE_PATH"
    
    xcodebuild archive \
        -scheme "$SCHEME" \
        -configuration "$CONFIGURATION" \
        -destination "generic/platform=macOS" \
        -archivePath "$ARCHIVE_PATH" \
        -allowProvisioningUpdates \
        BUILD_DIR="$PROJECT_ROOT/build" \
        PRODUCT_BUNDLE_IDENTIFIER="$BUNDLE_ID"
        
    if [ ! -d "$ARCHIVE_PATH" ]; then
        log_error "Archive 构建失败，未找到 .xcarchive 文件"
        exit 1
    fi
    
    log_success "Archive 构建完成"
}

export_app() {
    log_info "导出 .app 文件..."
    
    # 尝试使用 exportArchive
    if xcodebuild -exportArchive \
        -archivePath "$ARCHIVE_PATH" \
        -exportPath "$EXPORT_PATH" \
        -exportOptionsPlist "$EXPORT_OPTIONS_PATH" 2>/dev/null; then
        
        log_success "使用 exportArchive 导出成功"
        
    else
        log_warning "exportArchive 失败，使用兜底复制方案..."
        
        # 兜底方案：直接从 archive 复制
        ARCHIVE_APP_PATH="$ARCHIVE_PATH/Products/Applications/$APP_NAME"
        
        if [ -d "$ARCHIVE_APP_PATH" ]; then
            cp -R "$ARCHIVE_APP_PATH" "$EXPORT_PATH/"
            log_success "使用兜底方案复制成功"
        else
            log_error "Archive 中未找到 $APP_NAME"
            log_error "检查路径: $ARCHIVE_APP_PATH"
            exit 1
        fi
    fi
    
    # 验证导出结果
    EXPORTED_APP_PATH="$EXPORT_PATH/$APP_NAME"
    if [ ! -d "$EXPORTED_APP_PATH" ]; then
        log_error "导出失败，未找到 $EXPORTED_APP_PATH"
        exit 1
    fi
    
    log_success "App 导出成功: $EXPORTED_APP_PATH"
}

create_zip() {
    log_info "创建 ZIP 压缩包..."
    
    # 删除已存在的 ZIP
    [ -f "$ZIP_PATH" ] && rm -f "$ZIP_PATH"
    
    # 进入导出目录并打包（确保 ZIP 内层级正确）
    cd "$EXPORT_PATH"
    
    if [ ! -d "$APP_NAME" ]; then
        log_error "在导出目录中未找到 $APP_NAME"
        exit 1
    fi
    
    zip -r "$ZIP_NAME" "$APP_NAME" -x "*.DS_Store"
    
    if [ ! -f "$ZIP_NAME" ]; then
        log_error "ZIP 创建失败"
        exit 1
    fi
    
    # 回到项目根目录
    cd "$PROJECT_ROOT"
    
    log_success "ZIP 创建成功: $ZIP_PATH"
}

show_results() {
    echo ""
    echo "🎉 打包完成！"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # ZIP 文件信息
    ZIP_SIZE=$(du -h "$ZIP_PATH" | cut -f1)
    echo "📦 ZIP 文件: $ZIP_PATH"
    echo "📏 文件大小: $ZIP_SIZE"
    
    # 检查 GitHub CLI
    if check_command "gh" 2>/dev/null; then
        echo ""
        echo "🚀 上传到 GitHub Releases："
        echo "   make release TAG=v1.0.0"
        echo "   # 或者"
        echo "   ./scripts/release_github.sh v1.0.0"
    else
        echo ""
        echo "💡 安装 GitHub CLI 后可一键发布:"
        echo "   brew install gh"
        echo "   gh auth login"
        echo "   make release TAG=v1.0.0"
    fi
    
    echo ""
    echo "📂 打开构建目录:"
    echo "   open build/ReleaseUnsigned"
    echo ""
    echo "📋 用户安装指引:"
    echo "   1. 下载并解压 DockLambda-macOS.zip"
    echo "   2. 拖入 /Applications 目录"  
    echo "   3. 首次打开时右键选择'打开'绕过 Gatekeeper"
    echo ""
}

# ==================== 主流程 ====================

main() {
    echo "🔨 DockLambda 未签名打包脚本"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # 检查工作目录
    if [ ! -f "$PROJECT_ROOT/DockLambda.xcodeproj/project.pbxproj" ]; then
        log_error "未找到 DockLambda.xcodeproj，请在项目根目录运行此脚本"
        exit 1
    fi
    
    # 检查必需工具
    log_info "检查必需工具..."
    check_command "xcodebuild" || exit 1
    check_command "zip" || exit 1
    
    if ! check_command "gh" 2>/dev/null; then
        log_warning "GitHub CLI (gh) 未安装，将跳过发布功能"
    fi
    
    # 执行打包流程
    cleanup_build
    create_export_options
    build_archive
    export_app
    create_zip
    show_results
    
    log_success "打包流程完成！"
}

# 脚本入口
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi