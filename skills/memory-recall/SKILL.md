---
name: memory-recall
description: |
  记忆检索技能。统一检索历史对话和沉淀的知识，支持语义搜索。
  触发条件：用户说"我们之前讨论过"/"上次怎么解决的"/"这个项目做过什么"。
compatibility: Antigravity IDE, Claude Code, Gemini CLI, OpenAI Codex, iFlow CLI
metadata:
  author: lanstar128
  version: "2.0"
---

# 记忆检索技能

统一检索历史对话和沉淀的知识。

## 一、路径配置

| 变量 | 路径 |
|------|------|
| `DATA_DIR` | `~/.ai-memory/data` |
| `CONVERSATIONS_DIR` | `~/.ai-memory/data/conversations` |
| `KNOWLEDGE_DIR` | `~/.ai-memory/data/knowledge` |
| `MODELS_DIR` | `~/.ai-memory/models` |
| `SKILLS_DIR` | `~/.ai-memory/skills/skills` |

---

## 二、触发条件

| 触发词 | 场景 |
|--------|------|
| "我们之前讨论过..." | 查找历史对话 |
| "上次这个问题怎么解决的" | 查找知识 |
| "这个项目我们做过什么" | 按项目过滤 |

---

## 三、检索流程

### 3.1 语义搜索

```bash
python3 ~/.ai-memory/skills/skills/memory-recall/scripts/search.py \
  --query "对话归档怎么实现的" \
  --data-dir ~/.ai-memory/data \
  --top 5
```

### 3.2 输出格式

```
找到 3 条相关记录:

[1] 对话归档技能实现 (2026-01-18)
    首句: 我准备使用这个折衷方案...
    相关度: 0.92
    类型: 对话
    文件: ~/.ai-memory/data/conversations/2026-01/...

[2] Git 冲突解决方法
    描述: 多设备同步时的冲突处理...
    相关度: 0.78
    类型: 知识
    文件: ~/.ai-memory/data/knowledge/git-conflict.md
```

---

## 四、检索范围

| 来源 | 路径 | 匹配字段 |
|------|------|---------|
| 对话归档 | `~/.ai-memory/data/conversations/` | 标题、首句 |
| 沉淀知识 | `~/.ai-memory/data/knowledge/` | 标题、内容 |
| 全局技能 | `~/.ai-memory/skills/skills/` | name、description |

---

## 五、模型管理

| 项目 | 说明 |
|------|------|
| 模型路径 | `~/.ai-memory/models/all-MiniLM-L6-v2/` |
| 模型大小 | 约 80MB |
| 首次下载 | 自动完成 |
| 离线使用 | 下载后可离线运行 |

---

*Last Updated: 2026-02-06*
