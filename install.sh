#!/bin/bash
set -e

echo "🧠 AI Memory Skills 安装程序"
echo "================================"

# 检测操作系统
OS="$(uname -s)"
if [[ "$OS" != "Darwin" && "$OS" != "Linux" ]]; then
    echo "❌ 不支持的操作系统: $OS"
    echo "本安装脚本仅支持 macOS 和 Linux"
    exit 1
fi

echo "✅ 检测到操作系统: $OS"

# 检测 AI 环境
INSTALL_PATHS=()

if [ -d "$HOME/.gemini/antigravity" ]; then
    INSTALL_PATHS+=("$HOME/.gemini/antigravity/skills")
    echo "✅ 检测到 Antigravity IDE"
fi

if [ -d "$HOME/.gemini" ]; then
    INSTALL_PATHS+=("$HOME/.gemini/skills")
    echo "✅ 检测到 Gemini CLI 环境"
fi

if [ -d "$HOME/.codex" ]; then
    INSTALL_PATHS+=("$HOME/.codex/skills")
    echo "✅ 检测到 Codex CLI 环境"
fi

if [ -d "$HOME/.iflow" ]; then
    INSTALL_PATHS+=("$HOME/.iflow/skills")
    echo "✅ 检测到 iFlow CLI 环境"
fi

if [ ${#INSTALL_PATHS[@]} -eq 0 ]; then
    echo "⚠️  未检测到任何支持的 AI 环境"
    echo "请先安装 Antigravity IDE、Gemini CLI、Codex 或 iFlow"
    exit 1
fi

echo ""
echo "将安装到以下位置:"
for path in "${INSTALL_PATHS[@]}"; do
    echo "  - $path"
done

echo ""
read -p "是否继续安装? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ 安装已取消"
    exit 0
fi

# 下载或使用本地文件
if [ -d "./skills" ]; then
    echo "✅ 使用本地技能文件"
    SKILLS_DIR="./skills"
else
    echo "📥 从 GitHub 下载..."
    TEMP_DIR=$(mktemp -d)
    git clone --depth 1 https://github.com/lanstar128/ai-memory-skills.git "$TEMP_DIR" || {
        echo "❌ 下载失败"
        exit 1
    }
    SKILLS_DIR="$TEMP_DIR/skills"
fi

# 安装技能
for install_path in "${INSTALL_PATHS[@]}"; do
    echo "📦 安装到 $install_path ..."
    mkdir -p "$install_path"
    cp -r "$SKILLS_DIR"/* "$install_path/"
    echo "✅ 完成"
done

# 创建 memory 目录
MEMORY_DIR="$HOME/.gemini/memory/conversations"
if [ ! -d "$MEMORY_DIR" ]; then
    echo "📂 创建记忆存储目录: $MEMORY_DIR"
    mkdir -p "$MEMORY_DIR"
fi

echo ""
echo "✅ 安装完成！"
echo ""
echo "📚 已安装的技能:"
echo "  - conversation-archive (对话归档)"
echo "  - memory-recall (记忆检索)"
echo "  - knowledge-deposit (经验沉淀)"
echo "  - memory-sync (跨设备同步)"
echo ""
echo "💡 使用提示:"
echo "  1. 在 AI 对话中说 '保存对话' 即可归档"
echo "  2. 说 '我们之前讨论过...' 触发记忆检索"
echo "  3. 对话数据存储在: $MEMORY_DIR"
echo ""
echo "🔗 更多文档: https://github.com/lanstar128/ai-memory-skills"
