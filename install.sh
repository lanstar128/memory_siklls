#!/bin/bash
# Memory Skills 安装脚本
# 支持: Claude Code, Gemini CLI, OpenAI Codex, iFlow CLI
# 项目地址: https://github.com/lanstar128/memory_siklls
#
# 用法:
#   curl -fsSL https://raw.githubusercontent.com/.../install.sh | bash
#   curl -fsSL https://raw.githubusercontent.com/.../install.sh | bash -s -- --with-semantic
#   curl -fsSL https://raw.githubusercontent.com/.../install.sh | bash -s -- --no-semantic

REPO_URL="https://github.com/lanstar128/memory_siklls.git"

# 临时目录：优先使用 $TMPDIR，回退到 $HOME/.cache（兼容 Termux）
if [ -n "$TMPDIR" ] && [ -w "$TMPDIR" ]; then
    TMP_DIR="$TMPDIR/memory_skills_install"
elif [ -w "/tmp" ]; then
    TMP_DIR="/tmp/memory_skills_install"
else
    TMP_DIR="$HOME/.cache/memory_skills_install"
fi

# 命令行参数
INSTALL_SEMANTIC=""  # 空=询问, yes=安装, no=跳过

# 解析参数
while [[ $# -gt 0 ]]; do
    case $1 in
        --with-semantic)
            INSTALL_SEMANTIC="yes"
            shift
            ;;
        --no-semantic)
            INSTALL_SEMANTIC="no"
            shift
            ;;
        *)
            shift
            ;;
    esac
done

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Memory Skills 安装脚本${NC}"
echo -e "${GREEN}  跨平台 AI 记忆技能包${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# 检测 AI 终端环境
detect_platform() {
    echo -e "${YELLOW}正在检测 AI 终端环境...${NC}"
    
    # 按优先级检测
    if [ -d "$HOME/.claude" ]; then
        PLATFORM="claude"
        SKILL_DIR="$HOME/.claude/skills"
        MEMORY_DIR="$HOME/.claude/memory"
        CONFIG_FILE="$HOME/.claude/CLAUDE.md"
        echo -e "${GREEN}✓ 检测到 Claude Code${NC}"
    elif [ -d "$HOME/.gemini" ]; then
        PLATFORM="gemini"
        SKILL_DIR="$HOME/.gemini/skills"
        MEMORY_DIR="$HOME/.gemini/memory"
        CONFIG_FILE="$HOME/.gemini/GEMINI.md"
        echo -e "${GREEN}✓ 检测到 Gemini CLI${NC}"
    elif [ -d "$HOME/.codex" ]; then
        PLATFORM="codex"
        SKILL_DIR="$HOME/.codex/skills"
        MEMORY_DIR="$HOME/.codex/memory"
        CONFIG_FILE="$HOME/.codex/AGENTS.md"
        echo -e "${GREEN}✓ 检测到 OpenAI Codex${NC}"
    else
        # 默认使用 Gemini 目录结构
        PLATFORM="gemini"
        SKILL_DIR="$HOME/.gemini/skills"
        MEMORY_DIR="$HOME/.gemini/memory"
        CONFIG_FILE="$HOME/.gemini/GEMINI.md"
        echo -e "${YELLOW}未检测到已知平台，使用默认 Gemini 目录结构${NC}"
    fi
    
    echo "  技能目录: $SKILL_DIR"
    echo "  记忆目录: $MEMORY_DIR"
    echo ""
}

# 检查依赖
check_dependencies() {
    echo -e "${YELLOW}检查依赖...${NC}"
    
    # 检查 Git
    if ! command -v git &> /dev/null; then
        echo -e "${RED}✗ Git 未安装${NC}"
        echo "  请先安装 Git:"
        echo "    macOS: brew install git"
        echo "    Termux: pkg install git"
        echo "    Ubuntu: apt install git"
        exit 1
    fi
    echo -e "${GREEN}✓ Git 已安装${NC}"
    
    # 检查 Python3
    if ! command -v python3 &> /dev/null; then
        echo -e "${RED}✗ Python3 未安装${NC}"
        echo "  请先安装 Python3:"
        echo "    macOS: brew install python3"
        echo "    Termux: pkg install python"
        echo "    Ubuntu: apt install python3"
        exit 1
    fi
    echo -e "${GREEN}✓ Python3 已安装${NC}"
    echo ""
}

# 下载技能包
download_skills() {
    echo -e "${YELLOW}下载技能包...${NC}"
    echo "  临时目录: $TMP_DIR"
    
    # 确保临时目录的父目录存在
    mkdir -p "$(dirname "$TMP_DIR")"
    
    # 清理临时目录
    rm -rf "$TMP_DIR"
    
    # 克隆仓库（显示进度，不隐藏错误）
    if git clone --depth 1 "$REPO_URL" "$TMP_DIR"; then
        echo -e "${GREEN}✓ 下载完成${NC}"
        echo ""
        return 0
    else
        echo -e "${RED}✗ 下载失败${NC}"
        echo "  请检查网络连接，或手动下载:"
        echo "  git clone $REPO_URL"
        exit 1
    fi
}

# 安装技能
install_skills() {
    echo -e "${YELLOW}安装技能到 $SKILL_DIR ...${NC}"
    
    # 检查源文件是否存在
    if [ ! -d "$TMP_DIR/skills" ]; then
        echo -e "${RED}✗ 下载的文件不完整，缺少 skills 目录${NC}"
        exit 1
    fi
    
    # 创建目录
    mkdir -p "$SKILL_DIR"
    mkdir -p "$MEMORY_DIR/conversations"
    
    # 复制技能文件
    if cp -r "$TMP_DIR/skills/"* "$SKILL_DIR/"; then
        echo -e "${GREEN}✓ 技能文件复制成功${NC}"
    else
        echo -e "${RED}✗ 技能文件复制失败${NC}"
        exit 1
    fi
    echo ""
}

# 验证安装
verify_installation() {
    echo -e "${YELLOW}验证安装...${NC}"
    
    local installed_count=0
    local expected_skills=("conversation-archive" "memory-recall" "memory-sync" "knowledge-deposit")
    
    for skill in "${expected_skills[@]}"; do
        if [ -f "$SKILL_DIR/$skill/SKILL.md" ]; then
            echo -e "${GREEN}✓ $skill${NC}"
            ((installed_count++))
        else
            echo -e "${RED}✗ $skill (未找到)${NC}"
        fi
    done
    
    echo ""
    
    if [ $installed_count -eq ${#expected_skills[@]} ]; then
        echo -e "${GREEN}✓ 全部 $installed_count 个技能安装成功！${NC}"
        return 0
    elif [ $installed_count -gt 0 ]; then
        echo -e "${YELLOW}⚠ 部分安装: $installed_count/${#expected_skills[@]} 个技能${NC}"
        return 0
    else
        echo -e "${RED}✗ 安装验证失败：没有找到任何技能${NC}"
        return 1
    fi
}

# 安装语义搜索依赖
install_semantic_search() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  📦 可选：语义搜索增强${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
    echo "语义搜索可以让 AI 更智能地检索你的历史对话。"
    echo "需要安装 sentence-transformers 库（约 500MB）"
    echo ""
    
    local do_install=""
    
    # 根据命令行参数或交互决定
    if [ "$INSTALL_SEMANTIC" = "yes" ]; then
        do_install="yes"
        echo -e "${YELLOW}已通过 --with-semantic 参数指定安装${NC}"
    elif [ "$INSTALL_SEMANTIC" = "no" ]; then
        do_install="no"
        echo -e "${YELLOW}已通过 --no-semantic 参数跳过${NC}"
    elif [ -t 0 ]; then
        # 交互模式：询问用户
        echo -e "${YELLOW}是否安装语义搜索依赖？${NC}"
        echo "  [y] 是，立即安装"
        echo "  [n] 否，稍后手动安装"
        echo ""
        read -r -p "请选择 [y/n]: " choice
        case "$choice" in
            y|Y) do_install="yes" ;;
            *) do_install="no" ;;
        esac
    else
        # 非交互模式且无参数：显示如何安装
        echo -e "${YELLOW}非交互模式，跳过语义搜索安装${NC}"
        echo ""
        echo "如需安装语义搜索，请使用以下方式之一："
        echo -e "  ${GREEN}方式1: 重新运行安装脚本并添加参数${NC}"
        echo "    curl -fsSL https://raw.githubusercontent.com/lanstar128/memory_siklls/main/install.sh | bash -s -- --with-semantic"
        echo ""
        echo -e "  ${GREEN}方式2: 手动安装${NC}"
        echo "    pip3 install sentence-transformers"
        echo ""
        return
    fi
    
    # 执行安装
    if [ "$do_install" = "yes" ]; then
        echo ""
        echo -e "${YELLOW}正在安装 sentence-transformers...${NC}"
        echo "（这可能需要几分钟，取决于网络速度）"
        echo ""
        if pip3 install sentence-transformers; then
            echo ""
            echo -e "${GREEN}✓ 语义搜索依赖安装成功！${NC}"
        else
            echo ""
            echo -e "${RED}✗ 安装失败${NC}"
            echo "  请稍后手动安装: pip3 install sentence-transformers"
        fi
    else
        echo ""
        echo "如需安装，请稍后运行："
        echo -e "  ${GREEN}pip3 install sentence-transformers${NC}"
    fi
    echo ""
}

# 清理
cleanup() {
    rm -rf "$TMP_DIR"
}

# 完成提示
show_complete() {
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  ✅ 安装完成！${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo "已安装到: $SKILL_DIR"
    echo ""
    echo -e "${YELLOW}快速开始:${NC}"
    echo "  1. 在任务完成时说 \"帮我保存对话\" → 触发对话归档"
    echo "  2. 说 \"我们之前讨论过 XXX\" → 触发记忆检索"
    echo "  3. 说 \"同步记忆\" → 备份到远程 Git"
    echo ""
    echo -e "GitHub: ${GREEN}https://github.com/lanstar128/memory_siklls${NC}"
}

# 主流程
main() {
    detect_platform
    check_dependencies
    download_skills
    install_skills
    
    # 验证安装
    if ! verify_installation; then
        echo -e "${RED}安装可能不完整，请检查错误信息${NC}"
        cleanup
        exit 1
    fi
    
    cleanup
    install_semantic_search
    show_complete
}

main
