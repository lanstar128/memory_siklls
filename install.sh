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
    echo ""
    echo "  请输入你的私人记忆仓库地址"
    echo "  （如果没有，请先在 GitHub/Gitee 创建一个空的私有仓库）"
    echo "  （确保已配置好 SSH 密钥或 HTTPS 凭据）"
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
            echo "    3. 没有访问权限（SSH 密钥未配置）"
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
