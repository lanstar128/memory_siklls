#!/bin/bash
# 刷新技能聚合目录
# 该脚本会将 public skills 和 private skills 聚合到 ~/.ai-memory/current_skills

set -e

MEMORY_ROOT="$HOME/.ai-memory"
SKILLS_PUBLIC="$MEMORY_ROOT/skills/skills"
SKILLS_PRIVATE="$MEMORY_ROOT/data/skills"
AGGREGATE_DIR="$MEMORY_ROOT/current_skills"

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔄 正在刷新技能聚合...${NC}"

# 1. 准备聚合目录
mkdir -p "$AGGREGATE_DIR"

# 2. 定义链接创建函数 (复用 install.sh 的多平台逻辑)
create_symlink() {
    local source=$1
    local name=$(basename "$source")
    local target="$AGGREGATE_DIR/$name"
    
    # 检测源是否存在
    if [ ! -d "$source" ]; then
        return
    fi

    # 清理旧链接
    if [ -L "$target" ]; then
        rm "$target"
    elif [ -d "$target" ]; then
        # 如果是目录但不是链接，说明可能是残留，备份它
        mv "$target" "${target}.bak.$(date +%s)"
    fi

    # 创建链接
    case "$OSTYPE" in
        msys*|cygwin*)
            # Windows
            local win_source=$(cygpath -w "$source" 2>/dev/null || echo "$source")
            local win_target=$(cygpath -w "$target" 2>/dev/null || echo "$target")
            
            if cmd //c "mklink /D \"$win_target\" \"$win_source\"" &>/dev/null; then
                echo -e "  ${GREEN}+${NC} $name"
            elif command -v junction &>/dev/null; then
                junction "$target" "$source" >/dev/null
                echo -e "  ${GREEN}+${NC} $name"
            else
                # 只在Windows下回退复制，且仅当链接失败
                # 只有当聚合目录是全新的时候才复制，避免覆盖
                if [ ! -e "$target" ]; then
                     cp -r "$source" "$target"
                     echo -e "  ${YELLOW}*${NC} $name (复制)"
                fi
            fi
            ;;
        *)
            # Unix/Mac/Linux
            ln -s "$source" "$target"
            echo -e "  ${GREEN}+${NC} $name"
            ;;
    esac
}

# 3. 链接 Public Skills
if [ -d "$SKILLS_PUBLIC" ]; then
    echo "  加载公开技能..."
    for skill_dir in "$SKILLS_PUBLIC"/*; do
        if [ -d "$skill_dir" ]; then
            create_symlink "$skill_dir"
        fi
    done
fi

# 4. 链接 Private Skills (覆盖同名)
if [ -d "$SKILLS_PRIVATE" ]; then
    echo "  加载私有技能..."
    for skill_dir in "$SKILLS_PRIVATE"/*; do
        if [ -d "$skill_dir" ]; then
            name=$(basename "$skill_dir")
            # 如果已存在（即 Public 中有同名），先删除，实现覆盖
            if [ -e "$AGGREGATE_DIR/$name" ]; then
                echo -e "  ${YELLOW}^${NC} 覆盖公开技能: $name"
            fi
            create_symlink "$skill_dir"
        fi
    done
fi

echo -e "${GREEN}✅ 技能聚合完成${NC}"
