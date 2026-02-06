---
name: conversation-archive
description: |
  对话归档技能。在用户完成工作或明确要求保存时，引导用户导出对话并归档。
  触发条件：用户说"保存对话"/"归档"/"记录一下"，或检测到离开意图（"今天就到这"/"提交代码吧"）。
compatibility: Antigravity IDE, Claude Code, Gemini CLI, OpenAI Codex, iFlow CLI
metadata:
  author: lanstar128
  version: "2.1"
---

# 对话归档技能

## 一、触发条件

| 类型 | 示例 |
|------|------|
| **主动触发** | "保存对话"、"归档一下"、"记录这次对话" |
| **被动触发** | "今天就到这"、"提交代码吧"、"我先忙了" |

---

## 二、路径配置

| 变量 | 路径 |
|------|------|
| `DATA_DIR` | `~/.ai-memory/data` |
| `CONVERSATIONS_DIR` | `~/.ai-memory/data/conversations` |
| `SKILLS_DIR` | `~/.ai-memory/skills` |

---

## 三、归档流程

```
触发归档 → 检测环境 → 提取内容 → 生成元数据 → 保存文件 → 更新索引
```

### 3.1 获取对话内容

| 环境 | 方式 |
|------|------|
| Antigravity IDE | 引导用户导出到 ~/Downloads/，然后读取 |
| Gemini CLI | 读取日志文件 |
| Codex CLI | 读取会话日志 |
| 其他 | AI 自我转述当前对话 |

### 3.2 保存归档文件

```bash
CONVERSATIONS_DIR=~/.ai-memory/data/conversations
mkdir -p $CONVERSATIONS_DIR/$(date +%Y-%m)

cat > $CONVERSATIONS_DIR/$(date +%Y-%m)/$(date +%Y-%m-%d)_<标题>.md << 'EOF'
---
date: $(date +%Y-%m-%d %H:%M)
source: <来源>
project: <项目路径>
---
# <标题>

## 摘要
<摘要内容>

## 对话记录
<对话内容>
EOF
```

---

## 四、确认完成

```
✅ 对话已归档

位置: ~/.ai-memory/data/conversations/2026-02/2026-02-06_对话标题.md
对话轮数: N 轮
```

---

## 五、配套脚本

| 脚本 | 功能 |
|------|------|
| `scripts/inject_timestamps.py` | 时间戳注入 |
| `scripts/db_manager.py` | 索引管理 |
| `scripts/dedup_archives.py` | 去重检查 |

---

*Last Updated: 2026-02-06*