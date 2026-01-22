---
name: conversation-archive
description: |
  对话归档技能。在用户完成工作或明确要求保存时，引导用户导出对话并归档。
  触发条件：用户说"保存对话"/"归档"/"记录一下"，或检测到离开意图（"今天就到这"/"提交代码吧"）。
compatibility: Antigravity IDE, Claude Code, Gemini CLI, OpenAI Codex, iFlow CLI
metadata:
  author: lanstar128
  version: "2.0"
---

# 对话归档技能

## 一、触发条件

| 类型 | 示例 |
|------|------|
| **主动触发** | "保存对话"、"归档一下"、"记录这次对话" |
| **被动触发** | "今天就到这"、"提交代码吧"、"我先忙了" |

---

## 二、统一路径配置

### 2.1 确定根目录

AI 应根据当前运行环境确定根目录 (`ROOT_DIR`)：

| 环境 | 根目录路径 |
|------|-----------|
| **Antigravity / Gemini CLI** | `~/.gemini` |
| **Claude Code** | `~/.claude` |
| **Codex CLI** | `~/.codex` |
| **iFlow CLI** | `~/.iflow` |

### 2.2 路径变量

| 变量 | 路径 |
|------|------|
| `SKILL_BASE` | `${ROOT_DIR}/skills/conversation-archive` |
| `MEMORY_BASE` | `${ROOT_DIR}/memory/conversations` |
| `TMP_DIR` | `${ROOT_DIR}/tmp` |

---

## 三、归档流程总览

```
┌─────────────────────────────────────────────────────────┐
│                    触发归档                               │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│  Step 1: 检测环境 → 选择获取方式                          │
│  ┌──────────┬──────────┬──────────┬──────────┐         │
│  │Antigravity│ Codex CLI│Gemini CLI│  其他    │         │
│  │ 文件导入  │ 日志解析 │ 日志解析 │ AI 转述  │         │
│  └──────────┴──────────┴──────────┴──────────┘         │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│  Step 2: 提取/生成元数据 (JSON)                          │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│  Step 3: 保存归档文件 + 更新索引 + 去重                   │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│  Step 4: Git 同步 + 确认完成                             │
└─────────────────────────────────────────────────────────┘
```

---

## 四、Step 1 - 获取对话内容（按平台）

### 4.1 Antigravity IDE（文件导入）

1. **引导用户导出**：
   ```
   检测到您准备结束本次对话。是否需要归档？
   请点击右上角 Export 按钮，保存到 ~/Downloads/，完成后告诉我。
   ```

2. **检测导出文件**：
   ```bash
   ls -lt ~/Downloads/*.md | head -5
   ```

3. **提取时间戳**（从 `<ADDITIONAL_METADATA>` 中）：
   ```xml
   <ADDITIONAL_METADATA>
   The current local time is: 2026-01-18T11:43:11+08:00
   </ADDITIONAL_METADATA>
   ```
   > 截断的对话仅能恢复部分时间戳，不影响归档。

---

### 4.2 Codex CLI（日志解析）

会话日志位置：`~/.codex/sessions/YYYY/MM/DD/rollout-*.jsonl`

```bash
python3 $SKILL_BASE/scripts/codex_export.py --latest --title "<标题>"
```

---

### 4.3 Gemini CLI（日志解析）

```bash
python3 $SKILL_BASE/scripts/gemini_to_markdown.py --title "<标题>"
```

---

### 4.4 其他平台（AI 自我转述）

AI 自动总结当前上下文：
- 日期、标题、摘要
- 关键问答对复述

直接写入归档文件：
```bash
mkdir -p $MEMORY_BASE/$(date +%Y-%m)
cat > $MEMORY_BASE/$(date +%Y-%m)/$(date +%Y-%m-%d)_<标题>.md << 'EOF'
---
date: $(date +%Y-%m-%d %H:%M)
source: ai-self-archive
---
# <标题>

## 摘要
<摘要内容>

## 对话记录
<AI 复述的对话内容>
EOF
```

---

## 五、Step 2 - 生成元数据 JSON

所有模式统一输出格式：

```json
{
  "conversation_title": "对话标题",
  "archive_time": "2026-01-18 11:50",
  "project_path": "/Users/.../project",
  "turns": [
    {"index": 1, "time": "2026-01-18 09:55", "first_line": "用户第一句话..."}
  ]
}
```

保存到临时文件：
```bash
cat > $TMP_DIR/archive_metadata.json << 'EOF'
{ ... JSON 内容 ... }
EOF
```

---

## 六、Step 3 - 保存归档 + 更新索引

### 6.1 注入时间戳（仅 Antigravity）

```bash
python3 $SKILL_BASE/scripts/inject_timestamps.py \
  --source ~/Downloads/<对话标题>.md \
  --metadata $TMP_DIR/archive_metadata.json \
  --output $MEMORY_BASE/
```

### 6.2 更新索引（所有模式）

```bash
python3 $SKILL_BASE/scripts/db_manager.py \
  --action add \
  --metadata $TMP_DIR/archive_metadata.json \
  --file <归档文件路径>
```

### 6.3 去重检查

```bash
python3 $SKILL_BASE/scripts/dedup_archives.py \
  --dir $MEMORY_BASE/<年-月>/
```

### 6.4 清理临时文件

```bash
rm $TMP_DIR/archive_metadata.json
```

---

## 七、Step 4 - 同步 + 确认

### 7.1 Git 同步

```bash
```bash
cd ${ROOT_DIR} && git add . && git commit -m "auto: archive conversation" && git push
```
```

### 7.2 确认完成

```
✅ 对话已归档

位置: ${MEMORY_BASE}/2026-01/2026-01-18_对话标题.md
对话轮数: N 轮
时间范围: 09:55 - 11:50

索引已更新，可随时检索历史对话。
```

---

## 八、检索历史对话

```bash
python3 $SKILL_BASE/scripts/db_manager.py \
  --action search \
  --keyword "关键词" \
  --date-range "2026-01-01,2026-01-31"
```

---

## 九、存储结构

```
```
${ROOT_DIR}/memory/
├── conversations/
│   ├── 2026-01/
│   │   └── 2026-01-18_对话标题.md
│   └── 2026-02/
├── conversations.db      # SQLite 索引
└── index_backup.json     # JSON 备份
```

---

## 十、脚本清单

| 脚本 | 功能 |
|------|------|
| `inject_timestamps.py` | 时间戳注入 Markdown |
| `codex_export.py` | Codex 会话导出 |
| `gemini_to_markdown.py` | Gemini 会话导出 |
| `db_manager.py` | 索引管理 (增删查) |
| `dedup_archives.py` | 去重检查 |

---

*Last Updated: 2026-01-22*