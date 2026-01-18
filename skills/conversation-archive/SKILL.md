---
name: conversation-archive
description: |
  对话归档技能。在用户完成工作或明确要求保存时，引导用户导出对话并归档。
  触发条件：用户说"保存对话"/"归档"/"记录一下"，或检测到离开意图（"今天就到这"/"提交代码吧"）。
  用于指导 AI 如何正确地归档对话记录，包括时间戳提取和索引管理。
source: 用户需求设计
confidence: high
last_verified: 2026-01-18
---

# 对话归档技能

本技能指导 AI 在用户完成工作时，引导用户导出对话并进行归档处理。

---

## 一、触发条件

### 1.1 主动触发（用户明确要求）
- 用户说"保存对话"、"归档一下"、"记录这次对话"
- 用户说"帮我保存"、"存一下"

### 1.2 被动触发（检测到离开意图）
- 用户说"今天就到这"、"我先忙了"、"下次继续"
- 用户说"提交代码吧"、"commit 一下"
- 明显的任务完成迹象

---

## 二、执行流程

### 2.1 引导用户导出
```
检测到您准备结束本次对话。是否需要归档？

如需归档，请：
1. 点击对话窗口右上角的 "Export" 按钮
2. 保存到默认位置 (~/Downloads/)
3. 完成后告诉我"导出好了"
```

### 2.2 检测导出文件
用户确认后，扫描下载目录：
```bash
ls -lt ~/Downloads/*.md | head -5
```
- 查找最近 5 分钟内修改的 `.md` 文件
- 文件名格式：`{对话标题}.md`

### 2.3 提取时间戳元数据

> [!CAUTION]
> **关键步骤：时间戳必须从 ADDITIONAL_METADATA 中提取！**

每条用户消息的 `<ADDITIONAL_METADATA>` 块中包含：
```xml
<ADDITIONAL_METADATA>
The current local time is: 2026-01-18T11:43:11+08:00
...
</ADDITIONAL_METADATA>
```

**部分时间戳恢复**：
- 如果对话**全部在 active context 中**：可以完美恢复所有时间戳
- 如果对话**过长被截断**：只能恢复最近部分的时间戳
- 恢复策略：从当前内存中提取能找到的时间戳，其余留空
- **缺少时间戳不影响归档和检索功能**

**输出 JSON 格式**：
```json
{
  "conversation_title": "对话标题",
  "archive_time": "2026-01-18 11:50",
  "project_path": "/Users/.../project",
  "turns": [
    {"index": 1, "time": "2026-01-18 09:55", "first_line": "用户第一句话..."},
    {"index": 2, "time": "2026-01-18 10:30", "first_line": "用户第二句话..."}
  ]
}
```

### 2.4 调用脚本处理

**步骤 1：创建临时元数据文件**
```bash
cat > /tmp/archive_metadata.json << 'EOF'
{上一步的 JSON 内容}
EOF
```

**步骤 2：执行归档脚本**
```bash
# 注入时间戳并保存到全局目录
python3 ~/.gemini/skills/conversation-archive/scripts/inject_timestamps.py \
  --source ~/Downloads/对话标题.md \
  --metadata /tmp/archive_metadata.json \
  --output ~/.gemini/memory/conversations/

# 更新全局索引
python3 ~/.gemini/skills/conversation-archive/scripts/db_manager.py \
  --action add \
  --metadata /tmp/archive_metadata.json \
  --file <输出的归档文件路径>

# 清理临时文件
rm /tmp/archive_metadata.json

# 去重检查（合并同一对话的多次导出）
python3 ~/.gemini/skills/conversation-archive/scripts/dedup_archives.py \
  --dir ~/.gemini/memory/conversations/<年-月>/
```

**步骤 3：自动同步到远程**
```bash
git -C ~/.gemini add . && git -C ~/.gemini commit -m "auto: archive conversation" && git -C ~/.gemini push
```

### 2.5 确认完成
```
✅ 对话已归档

位置: ~/.gemini/memory/conversations/2026-01/2026-01-18_对话标题.md
对话轮数: N 轮
时间范围: 09:55 - 11:50

全局索引已更新，可随时检索历史对话。
```

---

## 三、存储结构

```
~/.gemini/memory/
├── conversations/          # 对话原文
│   ├── 2026-01/
│   │   └── 2026-01-18_对话归档技能讨论.md
│   └── 2026-02/
│       └── ...
├── conversations.db        # SQLite 索引
└── index_backup.json       # JSON 备份
```

> [!NOTE]
> 所有对话保存在全局目录，便于统一备份和跨设备同步。

---

## 四、检索历史对话

当用户需要查找历史对话时：
```bash
python3 ~/.gemini/skills/conversation-archive/scripts/db_manager.py \
  --action search \
  --keyword "关键词" \
  --date-range "2026-01-01,2026-01-31"
```

---

## 五、相关脚本

| 脚本 | 功能 |
|------|------|
| `scripts/inject_timestamps.py` | 将时间戳注入 Markdown 文件 |
| `scripts/db_manager.py` | SQLite 索引管理（增删查） |

---

*Created: 2026-01-18*
