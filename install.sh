#!/bin/bash
# AI Memory System 安装器
# 用法: curl -sSL https://raw.githubusercontent.com/lanstar128/AI_memory_siklls/main/install.sh | bash

set -e

# ==================== 颜色定义 ====================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ==================== 全局变量 ====================
MEMORY_ROOT="${AMS_MEMORY_ROOT:-$HOME/.ai-memory}"
SKILLS_REPO="${AMS_SKILLS_REPO:-https://github.com/lanstar128/AI_memory_siklls.git}"
PRESET_DATA_REPO="${AMS_DATA_REPO:-}"
SKIP_AUTH_SETUP="${AMS_SKIP_AUTH:-0}"
SKIP_DATA_REPO_SETUP="${AMS_SKIP_DATA_REPO:-0}"

# 环境检测结果
OS_TYPE=""
PKG_MANAGER=""
HAS_SSH_KEY=false
HAS_GH_AUTH=false
HAS_GH_CLI=false

# 为 curl | bash 模式准备 TTY 输入（非交互环境回退 stdin）
if { exec 3</dev/tty; } 2>/dev/null; then
    :
else
    exec 3<&0
fi

# ==================== 第一步：环境检测 ====================
detect_environment() {
    echo -e "${BLUE}🔍 检测系统环境...${NC}"
    
    # 检测操作系统
    case "$OSTYPE" in
        darwin*)
            OS_TYPE="macos"
            if command -v brew &>/dev/null; then
                PKG_MANAGER="brew"
            fi
            ;;
        linux-gnu*)
            OS_TYPE="linux"
            if command -v apt &>/dev/null; then
                PKG_MANAGER="apt"
            elif command -v dnf &>/dev/null; then
                PKG_MANAGER="dnf"
            elif command -v pacman &>/dev/null; then
                PKG_MANAGER="pacman"
            elif command -v yum &>/dev/null; then
                PKG_MANAGER="yum"
            fi
            ;;
        linux-android*)
            OS_TYPE="termux"
            PKG_MANAGER="pkg"
            ;;
        msys*|cygwin*)
            OS_TYPE="windows"
            if command -v winget &>/dev/null; then
                PKG_MANAGER="winget"
            elif command -v scoop &>/dev/null; then
                PKG_MANAGER="scoop"
            elif command -v choco &>/dev/null; then
                PKG_MANAGER="choco"
            fi
            ;;
        *)
            OS_TYPE="unknown"
            ;;
    esac
    
    # 检测 Git
    if ! command -v git &>/dev/null; then
        echo -e "  ${RED}❌ 未检测到 Git${NC}"
        echo "  请先安装 Git: https://git-scm.com"
        exit 1
    fi
    echo -e "  ${GREEN}✓${NC} Git 已安装"
    
    # 检测 SSH 密钥
    if ls ~/.ssh/id_* &>/dev/null; then
        HAS_SSH_KEY=true
        echo -e "  ${GREEN}✓${NC} SSH 密钥已配置"
    else
        echo -e "  ${YELLOW}○${NC} 未检测到 SSH 密钥"
    fi
    
    # 检测 GitHub CLI
    if command -v gh &>/dev/null; then
        HAS_GH_CLI=true
        if gh auth status &>/dev/null; then
            HAS_GH_AUTH=true
            echo -e "  ${GREEN}✓${NC} GitHub CLI 已授权"
        else
            echo -e "  ${YELLOW}○${NC} GitHub CLI 未授权"
        fi
    else
        echo -e "  ${YELLOW}○${NC} GitHub CLI 未安装"
    fi
    
    echo -e "  ${GREEN}✓${NC} 系统: $OS_TYPE, 包管理器: ${PKG_MANAGER:-无}"
    echo ""
}

# ==================== 工具函数：安装 GitHub CLI ====================
install_gh_cli() {
    echo "  正在安装 GitHub CLI..."
    
    case "$OS_TYPE" in
        macos)
            if [ "$PKG_MANAGER" = "brew" ]; then
                brew install gh
            else
                echo -e "  ${RED}❌ 请先安装 Homebrew${NC}"
                echo "  运行: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
                return 1
            fi
            ;;
        linux)
            case "$PKG_MANAGER" in
                apt)
                    sudo apt install gh -y 2>/dev/null || {
                        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
                        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
                        sudo apt update && sudo apt install gh -y
                    }
                    ;;
                dnf)
                    sudo dnf install gh -y
                    ;;
                pacman)
                    sudo pacman -S github-cli --noconfirm
                    ;;
                yum)
                    sudo yum install gh -y
                    ;;
                *)
                    echo -e "  ${RED}❌ 无法自动安装${NC}"
                    echo "  请手动安装: https://cli.github.com"
                    return 1
                    ;;
            esac
            ;;
        termux)
            pkg install gh -y
            ;;
        windows)
            case "$PKG_MANAGER" in
                winget)
                    winget install GitHub.cli
                    ;;
                scoop)
                    scoop install gh
                    ;;
                choco)
                    choco install gh -y
                    ;;
                *)
                    echo -e "  ${RED}❌ 请安装 winget、scoop 或 choco${NC}"
                    echo "  或手动安装: https://cli.github.com"
                    return 1
                    ;;
            esac
            ;;
        *)
            echo -e "  ${RED}❌ 不支持的系统${NC}"
            return 1
            ;;
    esac
    
    HAS_GH_CLI=true
    echo -e "  ${GREEN}✓${NC} GitHub CLI 安装成功"
}

# ==================== 工具函数：创建链接 ====================
create_link() {
    local tool_dir=$1
    local target=$2
    local name=$3
    # 允许传入自定义源路径（第四个参数），默认为聚合目录
    local source=${4:-"$MEMORY_ROOT/skills/skills"}
    
    if [ ! -d "$tool_dir" ]; then
        return
    fi
    
    # 确保父目录存在
    mkdir -p "$(dirname "$target")"
    
    # 清理已存在的目标
    if [ -L "$target" ]; then
        rm "$target"
    elif [ -d "$target" ]; then
        mv "$target" "${target}.bak.$(date +%s)"
    fi
    
    # 根据系统创建链接
    case "$OS_TYPE" in
        windows)
            local win_source=$(cygpath -w "$source" 2>/dev/null || echo "$source")
            local win_target=$(cygpath -w "$target" 2>/dev/null || echo "$target")
            
            if cmd //c "mklink /D \"$win_target\" \"$win_source\"" &>/dev/null; then
                echo -e "  ${GREEN}✓${NC} $name"
            elif command -v junction &>/dev/null; then
                junction "$target" "$source"
                echo -e "  ${GREEN}✓${NC} $name"
            else
                cp -r "$source" "$target"
                echo -e "  ${YELLOW}✓${NC} $name (复制模式)"
            fi
            ;;
        *)
            ln -s "$source" "$target"
            echo -e "  ${GREEN}✓${NC} $name"
            ;;
    esac
}

link_codex_skill_entries() {
    local source_root=$1
    local codex_skills_dir="$HOME/.codex/skills"

    [ -d "$HOME/.codex" ] || return 0
    [ -d "$source_root" ] || return 0

    mkdir -p "$codex_skills_dir"

    echo "  为 Codex 注入 AMS 技能（保留现有 ~/.codex/skills 内容）..."
    for skill_dir in "$source_root"/*; do
        [ -d "$skill_dir" ] || continue
        local name
        name=$(basename "$skill_dir")
        local target="$codex_skills_dir/$name"

        if [ -L "$target" ]; then
            rm "$target"
        elif [ -e "$target" ]; then
            echo -e "  ${YELLOW}!${NC} Codex 已存在同名技能，跳过: $name"
            continue
        fi

        ln -s "$skill_dir" "$target"
        echo -e "  ${GREEN}+${NC} Codex 技能: $name"
    done
}

# ==================== 第二步：配置 Git 授权 ====================
setup_git_auth() {
    if [ "$SKIP_AUTH_SETUP" = "1" ]; then
        echo "  已通过 AMS_SKIP_AUTH=1 跳过 GitHub 授权配置"
        return
    fi

    # 如果已有授权，跳过
    if [ "$HAS_SSH_KEY" = true ] || [ "$HAS_GH_AUTH" = true ]; then
        return
    fi
    
    echo -e "${YELLOW}⚠️ 未检测到 Git 授权配置${NC}"
    echo ""
    echo "  访问私有仓库需要授权，请选择："
    echo "    1) 使用 GitHub CLI 登录（推荐，自动打开浏览器）"
    echo "    2) 跳过（稍后手动配置 SSH 密钥）"
    echo ""
    printf "  请选择 [1/2]: "
    read auth_choice <&3
    
    if [[ "$auth_choice" != "1" ]]; then
        echo "  跳过授权配置"
        return
    fi
    
    # 安装 gh（如果需要）
    if [ "$HAS_GH_CLI" = false ]; then
        install_gh_cli || return
    fi
    
    # 进行 GitHub 登录（使用设备码模式）
    echo ""
    echo "  即将进行 GitHub 授权..."
    echo "  请在浏览器中完成授权后返回终端"
    echo ""
    
    # 根据系统打开浏览器
    case "$OS_TYPE" in
        macos)
            open "https://github.com/login/device" 2>/dev/null &
            ;;
        linux)
            xdg-open "https://github.com/login/device" 2>/dev/null &
            ;;
        windows)
            start "https://github.com/login/device" 2>/dev/null &
            ;;
        termux)
            termux-open-url "https://github.com/login/device" 2>/dev/null &
            ;;
    esac
    
    # 使用交互式登录
    if gh auth login --hostname github.com --git-protocol https <&3; then
        HAS_GH_AUTH=true
        echo -e "  ${GREEN}✓${NC} GitHub 授权成功"
    else
        echo -e "  ${YELLOW}⚠️${NC} 授权取消或失败"
    fi
}

ensure_data_layout() {
    mkdir -p "$MEMORY_ROOT/data/conversations" "$MEMORY_ROOT/data/knowledge" "$MEMORY_ROOT/data/profiles" "$MEMORY_ROOT/data/projects" "$MEMORY_ROOT/data/skills"

    local gitignore="$MEMORY_ROOT/data/.gitignore"
    if [ ! -f "$gitignore" ]; then
        cat > "$gitignore" <<'EOF'
.DS_Store
*.log
__pycache__/
secrets.env
*.tmp
EOF
    else
        grep -qxF 'secrets.env' "$gitignore" || echo 'secrets.env' >> "$gitignore"
    fi
}

# ==================== 第三步：安装技能仓库 ====================
install_skills_repo() {
    echo -e "${YELLOW}[1/4] 安装技能仓库...${NC}"
    
    mkdir -p "$MEMORY_ROOT"
    
    if [ -d "$MEMORY_ROOT/skills/.git" ]; then
        echo "  技能仓库已存在，正在更新..."
        git -C "$MEMORY_ROOT/skills" pull --quiet
    else
        if [ -d "$MEMORY_ROOT/skills" ]; then
            mv "$MEMORY_ROOT/skills" "$MEMORY_ROOT/skills.bak.$(date +%s)"
        fi
        git clone --quiet "$SKILLS_REPO" "$MEMORY_ROOT/skills"
    fi
    echo -e "  ${GREEN}✓${NC} 技能仓库就绪"
}

# ==================== 第四步：配置私人数据仓库 ====================
setup_data_repo() {
    echo ""
    echo -e "${YELLOW}[2/4] 配置私人数据仓库...${NC}"
    
    if [ -d "$MEMORY_ROOT/data/.git" ]; then
        echo -e "  ${GREEN}✓${NC} 私人数据仓库已存在"
        ensure_data_layout
        return
    fi

    if [ "$SKIP_DATA_REPO_SETUP" = "1" ]; then
        echo "  已通过 AMS_SKIP_DATA_REPO=1 跳过私人仓库配置"
        ensure_data_layout
        echo -e "  ${YELLOW}⚠️${NC} 当前为本地模式（未绑定远程仓库）"
        return
    fi
    
    echo ""
    echo "  请输入你的私人记忆仓库地址"
    echo "  （如果没有，请先在 GitHub 创建一个空的私有仓库）"
    if [ "$HAS_SSH_KEY" = true ]; then
        echo "  推荐格式: git@github.com:用户名/仓库名.git"
    else
        echo "  推荐格式: https://github.com/用户名/仓库名.git"
    fi
    echo ""
    
    while true; do
        printf "  仓库地址 (直接回车跳过): "
        if [ -n "$PRESET_DATA_REPO" ]; then
            data_repo="$PRESET_DATA_REPO"
            echo "$data_repo"
            PRESET_DATA_REPO=""
        else
            read data_repo <&3
        fi
        
        # 跳过
        if [ -z "$data_repo" ]; then
            echo "  跳过私人仓库配置"
            ensure_data_layout
            echo -e "  ${YELLOW}⚠️${NC} 已创建本地目录，稍后可手动关联仓库"
            return
        fi
        
        # 验证格式
        if [[ ! "$data_repo" =~ ^(git@|https://) ]]; then
            echo -e "  ${RED}❌ 无效格式，请使用 git@ 或 https:// 开头${NC}"
            continue
        fi
        
        # 验证可访问性
        echo "  正在验证仓库..."
        if git ls-remote "$data_repo" &>/dev/null; then
            echo -e "  ${GREEN}✓${NC} 仓库验证通过"
            
            mkdir -p "$MEMORY_ROOT/data"
            if git clone --quiet "$data_repo" "$MEMORY_ROOT/data" 2>/dev/null; then
                ensure_data_layout
                echo -e "  ${GREEN}✓${NC} 私人数据仓库已克隆"
            else
                cd "$MEMORY_ROOT/data"
                git init --quiet
                git remote add origin "$data_repo"
                ensure_data_layout
                git add .
                git commit -m "Initial: AI memory data" --quiet
                git branch -M main
                echo -e "  ${GREEN}✓${NC} 私人数据仓库已初始化"
                echo -e "  ${YELLOW}⚠️${NC} 请稍后执行 git push 推送到远程"
            fi
            return
        else
            echo -e "  ${RED}❌ 无法访问仓库${NC}"
            echo "  可能原因：地址错误 / 仓库不存在 / 没有权限"
            printf "  是否重试？[y/n]: "
            read retry <&3
            [[ "$retry" != "y" && "$retry" != "Y" ]] && {
                ensure_data_layout
                echo -e "  ${YELLOW}⚠️${NC} 已创建本地目录"
                return
            }
        fi
    done
}

# ==================== 第五步：创建工具链接 ====================
create_tool_links() {
    echo ""
    echo -e "${YELLOW}[3/4] 创建 AI 工具链接...${NC}"
    
    # 1. 执行技能聚合
    # 确保刷新脚本可执行
    if [ -f "$MEMORY_ROOT/skills/scripts/refresh_skills.sh" ]; then
        chmod +x "$MEMORY_ROOT/skills/scripts/refresh_skills.sh"
        AMS_MEMORY_ROOT="$MEMORY_ROOT" bash "$MEMORY_ROOT/skills/scripts/refresh_skills.sh"
    else
        echo -e "  ${RED}❌ 未找到刷新脚本，跳过聚合${NC}"
    fi

    local SKILLS_TARGET="$MEMORY_ROOT/current_skills"
    
    # 2. 链接各工具到聚合目录
    # (复用 create_link 工具函数，但源变为 current_skills)
    
    [ -d "$HOME/.gemini" ] && create_link "$HOME/.gemini" "$HOME/.gemini/skills" "Gemini CLI" "$SKILLS_TARGET"
    [ -d "$HOME/.gemini/antigravity" ] && create_link "$HOME/.gemini/antigravity" "$HOME/.gemini/antigravity/skills" "Antigravity IDE" "$SKILLS_TARGET"
    [ -d "$HOME/.claude" ] && create_link "$HOME/.claude" "$HOME/.claude/skills" "Claude Code" "$SKILLS_TARGET"
    link_codex_skill_entries "$SKILLS_TARGET"
    [ -d "$HOME/.iflow" ] && create_link "$HOME/.iflow" "$HOME/.iflow/skills" "iFlow CLI" "$SKILLS_TARGET"

    return 0
}

# ==================== 第六步：初始化配置 ====================
init_config() {
    echo ""
    echo -e "${YELLOW}[4/4] 初始化配置...${NC}"
    mkdir -p "$MEMORY_ROOT/models"
    ensure_data_layout
    echo -e "  ${GREEN}✓${NC} 模型目录就绪"
}

# ==================== 主流程 ====================
main() {
    echo ""
    echo -e "${BLUE}🧠 AI Memory System 安装器${NC}"
    echo "=============================="
    echo ""
    
    # 1. 检测环境
    detect_environment
    
    # 2. 配置授权（如需要）
    setup_git_auth
    echo ""
    
    # 3. 安装技能仓库
    install_skills_repo
    
    # 4. 配置私人数据仓库
    setup_data_repo
    
    # 5. 创建工具链接
    create_tool_links
    
    # 6. 初始化配置
    init_config
    
    # 完成
    echo ""
    echo "=============================="
    echo -e "${GREEN}✅ 安装完成！${NC}"
    echo ""
    echo "目录结构："
    echo "  ~/.ai-memory/"
    echo "  ├── skills/    ← 技能代码"
    echo "  ├── data/      ← 你的私人数据"
    echo "  └── models/    ← embedding 模型"
    echo ""
    echo "使用方法："
    echo "  • 同步记忆：在 AI 工具中说 \"同步记忆\""
    echo "  • 拉取记忆：在 AI 工具中说 \"拉取记忆\""
    echo "  • 更新技能：在 AI 工具中说 \"更新技能\""
    echo ""
}

# 执行主流程
main
