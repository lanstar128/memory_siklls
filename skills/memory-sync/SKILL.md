---
name: memory-sync
description: |
  记忆同步技能。将私人数据同步到远程 Git 仓库，支持多设备双向同步。
  触发条件：
  - "同步记忆"/"备份记忆"/"push 记忆" → 推送到远程
  - "拉取记忆"/"pull 记忆" → 从远程拉取
  - "更新技能" → 更新技能代码到最新版本
compatibility: Antigravity IDE, Claude Code, Gemini CLI, OpenAI Codex, iFlow CLI
metadata:
  author: lanstar128
  version: "2.0"
---

# 记忆同步技能

将私人数据 `~/.ai-memory/data/` 同步到远程 Git 仓库。

## 一、路径配置

| 变量 | 路径 | 说明 |
|------|------|------|
| `MEMORY_ROOT` | `~/.ai-memory` | 记忆系统根目录 |
| `DATA_DIR` | `~/.ai-memory/data` | 私人数据（Git 仓库） |
| `SKILLS_DIR` | `~/.ai-memory/skills` | 技能代码（Git 仓库） |

---

## 二、触发条件

| 触发词 | 动作 |
|--------|------|
| "同步记忆" / "备份记忆" / "push 记忆" | 推送私人数据到远程 |
| "拉取记忆" / "pull 记忆" | 从远程拉取私人数据 |
| "更新技能" | 拉取技能代码最新版本 |

---

## 三、同步操作

> [!CAUTION]
> **必须使用 `git -C ~/.ai-memory/data`**，避免和当前项目仓库冲突！

### 3.1 推送 (Push)

```bash
DATA_DIR=~/.ai-memory/data

# 1. 先拉取远程更新（避免冲突）
git -C $DATA_DIR pull --rebase

# 2. 提交并推送
git -C $DATA_DIR add .
git -C $DATA_DIR commit -m "sync: $(date '+%Y-%m-%d %H:%M') from $(hostname)"
git -C $DATA_DIR push
```

### 3.2 拉取 (Pull)

```bash
DATA_DIR=~/.ai-memory/data
git -C $DATA_DIR pull
```

### 3.3 更新技能

```bash
SKILLS_DIR=~/.ai-memory/skills
git -C $SKILLS_DIR pull
```

---

## 四、同步内容

| 目录/文件 | 说明 | 同步 |
|----------|------|------|
| `data/conversations/` | 对话归档 | ✅ |
| `data/knowledge/` | 沉淀的知识 | ✅ |
| `data/secrets.env` | 敏感配置 | ✅ |
| `skills/` | 技能代码 | ⬅️ 只读拉取 |

---

## 五、确认完成

### 推送成功
```
✅ 记忆已同步

仓库：~/.ai-memory/data（私人记忆）
推送：N 个文件变更
设备：$(hostname)
时间：$(date)
```

### 拉取成功
```
✅ 记忆已更新

仓库：~/.ai-memory/data
来源：origin/main
```

### 技能更新成功
```
✅ 技能已更新

仓库：~/.ai-memory/skills
版本：最新
```

---

## 六、首次设置

如果用户还没有运行过安装脚本，提示：

```
未检测到记忆系统，请先运行安装脚本：

curl -sSL https://raw.githubusercontent.com/lanstar128/AI_memory_siklls/main/install.sh | bash
```

---

*Last Updated: 2026-02-06*
