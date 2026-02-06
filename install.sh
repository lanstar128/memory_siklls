#!/bin/bash
# AI Memory System 安装器
# 用法: curl -sSL https://raw.githubusercontent.com/lanstar128/AI_memory_siklls/main/install.sh | bash

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

MEMORY_ROOT="$HOME/.ai-memory"
SKILLS_REPO="https://github.com/lanstar128/AI_memory_siklls.git"

# 为 curl | bash 模式准备 TTY 输入
# 打开 fd 3 连接到终端，用于读取用户输入
exec 3</dev/tty 2>/dev/null || exec 3<&0

echo ""
echo -e "${BLUE}🧠 AI Memory System 安装器${NC}"
echo "=============================="
echo ""

# 检查 Git
if ! command -v git &> /dev/null; then
    echo -e "${RED}❌ 未检测到 Git，请先安装 Git${NC}"
    exit 1
fi

# 创建根目录
mkdir -p "$MEMORY_ROOT"

# ==================== 技能仓库 ====================
echo -e "${YELLOW}[1/4] 安装技能仓库...${NC}"

if [ -d "$MEMORY_ROOT/skills/.git" ]; then
    echo "  技能仓库已存在，正在更新..."
    git -C "$MEMORY_ROOT/skills" pull --quiet
else
    if [ -d "$MEMORY_ROOT/skills" ]; then
        mv "$MEMORY_ROOT/skills" "$MEMORY_ROOT/skills.bak.$(date +%s)"
        echo "  已备份旧的 skills 目录"
    fi
    git clone --quiet "$SKILLS_REPO" "$MEMORY_ROOT/skills"
fi
echo -e "  ${GREEN}✓${NC} 技能仓库就绪"

# ==================== 私人数据仓库 ====================
echo ""
echo -e "${YELLOW}[2/4] 配置私人数据仓库...${NC}"

if [ -d "$MEMORY_ROOT/data/.git" ]; then
    echo -e "  ${GREEN}✓${NC} 私人数据仓库已存在"
else
    # ========== 检查 Git 授权状态 ==========
    HAS_SSH_KEY=false
    HAS_GH_AUTH=false
    
    # 检查 SSH 密钥
    if ls ~/.ssh/id_* &>/dev/null; then
        HAS_SSH_KEY=true
        echo -e "  ${GREEN}✓${NC} 检测到 SSH 密钥"
    fi
    
    # 检查 GitHub CLI 授权
    if command -v gh &>/dev/null && gh auth status &>/dev/null; then
        HAS_GH_AUTH=true
        echo -e "  ${GREEN}✓${NC} 检测到 GitHub CLI 已授权"
    fi
    
    # 如果两者都没有，需要配置授权
    if [ "$HAS_SSH_KEY" = false ] && [ "$HAS_GH_AUTH" = false ]; then
        echo -e "  ${YELLOW}⚠️${NC} 未检测到 Git 授权配置"
        echo ""
        echo "  访问私有仓库需要授权，请选择授权方式："
        echo "    1) 使用 GitHub CLI 登录（推荐，自动打开浏览器）"
        echo "    2) 跳过（稍后手动配置 SSH 密钥）"
        echo ""
        printf "  请选择 [1/2]: "
        read auth_choice <&3
        
        if [[ "$auth_choice" == "1" ]]; then
            # 检查并安装 GitHub CLI
            if ! command -v gh &>/dev/null; then
                echo ""
                echo "  需要安装 GitHub CLI..."
                
                # 检测操作系统并安装
                if [[ "$OSTYPE" == "darwin"* ]]; then
                    # macOS
                    if command -v brew &>/dev/null; then
                        echo "  正在使用 Homebrew 安装 gh..."
                        brew install gh
                    else
                        echo -e "  ${RED}❌ 未检测到 Homebrew${NC}"
                        echo "  请运行: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
                        echo "  然后运行: brew install gh"
                        echo ""
                        echo "  跳过授权配置..."
                    fi
                elif [[ "$OSTYPE" == "linux-gnu"* ]] || [[ "$OSTYPE" == "linux-android"* ]]; then
                    # Linux 或 Android Termux
                    if command -v apt &>/dev/null; then
                        echo "  正在使用 apt 安装 gh..."
                        if command -v pkg &>/dev/null; then
                            # Termux
                            pkg install gh -y
                        else
                            # Debian/Ubuntu
                            sudo apt install gh -y 2>/dev/null || {
                                echo "  需要添加 GitHub CLI 源..."
                                curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
                                echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
                                sudo apt update && sudo apt install gh -y
                            }
                        fi
                    elif command -v dnf &>/dev/null; then
                        # Fedora/RHEL
                        echo "  正在使用 dnf 安装 gh..."
                        sudo dnf install gh -y
                    elif command -v pacman &>/dev/null; then
                        # Arch Linux
                        echo "  正在使用 pacman 安装 gh..."
                        sudo pacman -S github-cli --noconfirm
                    else
                        echo -e "  ${RED}❌ 无法自动安装 gh${NC}"
                        echo "  请手动安装: https://cli.github.com"
                        echo ""
                        echo "  跳过授权配置..."
                    fi
                elif [[ "$OSTYPE" == "msys"* ]] || [[ "$OSTYPE" == "cygwin"* ]]; then
                    # Windows Git Bash / Cygwin
                    if command -v winget &>/dev/null; then
                        echo "  正在使用 winget 安装 gh..."
                        winget install GitHub.cli
                    elif command -v scoop &>/dev/null; then
                        echo "  正在使用 scoop 安装 gh..."
                        scoop install gh
                    else
                        echo -e "  ${RED}❌ 未检测到 winget 或 scoop${NC}"
                        echo "  请手动安装: https://cli.github.com"
                        echo ""
                        echo "  跳过授权配置..."
                    fi
                else
                    echo -e "  ${RED}❌ 不支持的操作系统: $OSTYPE${NC}"
                    echo "  请手动安装 GitHub CLI: https://cli.github.com"
                    echo ""
                    echo "  跳过授权配置..."
                fi
            fi
            
            # 进行 GitHub 登录
            if command -v gh &>/dev/null; then
                echo ""
                echo "  正在打开浏览器进行 GitHub 授权..."
                if gh auth login --web --git-protocol https; then
                    HAS_GH_AUTH=true
                    echo -e "  ${GREEN}✓${NC} GitHub 授权成功"
                else
                    echo -e "  ${YELLOW}⚠️${NC} 授权取消或失败"
                fi
            fi
        fi
    fi
    
    echo ""
    echo "  请输入你的私人记忆仓库地址"
    echo "  （如果没有，请先在 GitHub 创建一个空的私有仓库）"
    if [ "$HAS_SSH_KEY" = true ]; then
        echo "  推荐使用 SSH 格式: git@github.com:用户名/仓库名.git"
    else
        echo "  推荐使用 HTTPS 格式: https://github.com/用户名/仓库名.git"
    fi
    echo ""
    
    data_repo=""
    while true; do
        # 从 fd 3 读取用户输入（支持 curl | bash 模式）
        printf "  仓库地址 (直接回车跳过): "
        read data_repo <&3
        
        # 如果用户直接回车，跳过
        if [ -z "$data_repo" ]; then
            echo "  跳过私人仓库配置"
            mkdir -p "$MEMORY_ROOT/data/conversations" "$MEMORY_ROOT/data/knowledge"
            echo -e "  ${YELLOW}⚠️${NC} 已创建本地目录，稍后可手动关联仓库"
            break
        fi
        
        # 验证仓库地址格式
        if [[ ! "$data_repo" =~ ^(git@|https://) ]]; then
            echo -e "  ${RED}❌ 无效的仓库地址格式${NC}"
            echo "  请使用 SSH 格式 (git@github.com:user/repo.git)"
            echo "  或 HTTPS 格式 (https://github.com/user/repo.git)"
            echo ""
            continue
        fi
        
        # 验证仓库是否可访问
        echo "  正在验证仓库..."
        if git ls-remote "$data_repo" &>/dev/null; then
            echo -e "  ${GREEN}✓${NC} 仓库验证通过"
            
            # 克隆仓库
            mkdir -p "$MEMORY_ROOT/data"
            if git clone --quiet "$data_repo" "$MEMORY_ROOT/data" 2>/dev/null; then
                echo -e "  ${GREEN}✓${NC} 私人数据仓库已克隆"
            else
                # 仓库是空的，需要初始化
                cd "$MEMORY_ROOT/data"
                git init --quiet
                git remote add origin "$data_repo"
                
                # 创建初始目录结构
                mkdir -p conversations knowledge
                cat > .gitignore << 'EOF'
.DS_Store
*.log
__pycache__/
EOF
                git add .
                git commit -m "Initial: AI memory data" --quiet
                git branch -M main
                echo -e "  ${GREEN}✓${NC} 私人数据仓库已初始化"
                echo -e "  ${YELLOW}⚠️${NC} 请稍后手动执行 git push 推送到远程"
            fi
            break
        else
            echo -e "  ${RED}❌ 无法访问仓库${NC}"
            echo "  可能原因："
            echo "    1. 仓库地址错误"
            echo "    2. 仓库不存在"
            echo "    3. 没有访问权限"
            echo ""
            printf "  是否重试？[y/n]: "
            read retry <&3
            if [[ "$retry" != "y" && "$retry" != "Y" ]]; then
                echo "  跳过私人仓库配置"
                mkdir -p "$MEMORY_ROOT/data/conversations" "$MEMORY_ROOT/data/knowledge"
                echo -e "  ${YELLOW}⚠️${NC} 已创建本地目录，稍后可手动关联仓库"
                break
            fi
            echo ""
        fi
    done
fi

# ==================== 创建符号链接 ====================
echo ""
echo -e "${YELLOW}[3/4] 创建 AI 工具链接...${NC}"

create_link() {
    local tool_dir=$1
    local target=$2
    local name=$3
    
    if [ -d "$tool_dir" ]; then
        # 确保父目录存在
        mkdir -p "$(dirname "$target")"
        
        # 如果目标是符号链接，先删除
        if [ -L "$target" ]; then
            rm "$target"
        # 如果目标是普通目录，备份它
        elif [ -d "$target" ]; then
            mv "$target" "${target}.bak.$(date +%s)"
        fi
        
        # 创建符号链接
        ln -s "$MEMORY_ROOT/skills/skills" "$target"
        echo -e "  ${GREEN}✓${NC} $name"
    fi
}

# Gemini CLI
if [ -d "$HOME/.gemini" ]; then
    create_link "$HOME/.gemini" "$HOME/.gemini/skills" "Gemini CLI"
fi

# Antigravity IDE
if [ -d "$HOME/.gemini/antigravity" ]; then
    create_link "$HOME/.gemini/antigravity" "$HOME/.gemini/antigravity/skills" "Antigravity IDE"
fi

# Claude Code
if [ -d "$HOME/.claude" ]; then
    create_link "$HOME/.claude" "$HOME/.claude/skills" "Claude Code"
fi

# OpenAI Codex
if [ -d "$HOME/.codex" ]; then
    create_link "$HOME/.codex" "$HOME/.codex/skills" "Codex CLI"
fi

# iFlow
if [ -d "$HOME/.iflow" ]; then
    create_link "$HOME/.iflow" "$HOME/.iflow/skills" "iFlow CLI"
fi

# ==================== 创建模型目录 ====================
echo ""
echo -e "${YELLOW}[4/4] 初始化配置...${NC}"
mkdir -p "$MEMORY_ROOT/models"
echo -e "  ${GREEN}✓${NC} 模型目录就绪"

# ==================== 完成 ====================
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
