#!/bin/bash

# 发布到公开仓库的脚本
# 用法: bash scripts/publish-public.sh "提交信息"

set -e  # 遇到错误立即退出

PUBLIC_REMOTE="public"
TEMP_DIR="/tmp/ai-memory-skills-public-$$"
COMMIT_MSG="${1:-Sync from dev: $(date '+%Y-%m-%d %H:%M')}"

echo "🚀 开始发布到公开仓库..."

# 1. 克隆公开仓库到临时目录
echo "📦 克隆公开仓库..."
git clone https://github.com/lanstar128/AI_memory_siklls.git "$TEMP_DIR"

# 2. 复制文件（排除私有内容）
echo "📋 复制文件（排除私有内容）..."
rsync -av \
  --exclude='.git' \
  --exclude-from='.publish-ignore' \
  ./ "$TEMP_DIR/"

# 3. 提交并推送
echo "📤 提交并推送..."
cd "$TEMP_DIR"
git add .
git commit -m "$COMMIT_MSG" || echo "没有新的更改"
git push

# 4. 清理临时目录
echo "🧹 清理临时文件..."
rm -rf "$TEMP_DIR"

echo "✅ 发布到公开仓库成功！"
echo "🔗 公开仓库: https://github.com/lanstar128/AI_memory_siklls"
