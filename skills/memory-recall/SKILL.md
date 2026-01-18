---
name: memory-recall
description: |
  记忆检索技能。统一检索历史对话和经验沉淀，支持语义搜索。
  触发条件：用户说"我们之前讨论过"/"上次怎么解决的"/"这个项目做过什么"。
  使用本地 embedding 模型进行语义匹配，结果展示原文。
source: 用户需求设计
confidence: high
last_verified: 2026-01-18
---

# 记忆检索技能

统一检索历史对话（conversation-archive）和经验沉淀（knowledge-deposit）。

---

## 一、触发条件

| 触发词 | 场景 |
|--------|------|
| "我们之前讨论过..." | 查找历史对话 |
| "上次这个问题怎么解决的" | 查找经验 |
| "这个项目我们做过什么" | 按项目过滤 |
| "上周的对话" | 按时间范围 |

---

## 二、环境检查

### 2.1 Python 环境（必需）
执行前先检查 Python 是否可用：
```bash
which python3
```

如果返回空，提示用户：
```
⚠️ 未检测到 Python3 环境。

请安装 Python3（macOS 可运行）：
  brew install python3

或访问 https://www.python.org/downloads/
```

### 2.2 语义搜索依赖（可选）
首次运行 search.py 时会自动询问用户是否安装。

---

## 三、执行流程

### 3.1 语义搜索
```bash
python3 ~/.gemini/skills/memory-recall/scripts/search.py \
  --query "对话归档怎么实现的" \
  --top 5
```

输出格式：
```
找到 3 条相关记录:

[1] Conversation Archive Skill Implementation (2026-01-18)
    首句: 我准备使用这个折衷方案
    相关度: 0.92
    类型: 对话归档
    文件: .agent/memory/conversations/2026-01/...

[2] knowledge-deposit (技能)
    描述: 经验沉淀技能...
    相关度: 0.78
    类型: 技能文件
    文件: ~/.gemini/skills/knowledge-deposit/SKILL.md
```

### 3.2 查看详细内容
```bash
# 按 ID 显示原文（脚本直接读取，不经 AI 处理）
python3 ~/.gemini/skills/memory-recall/scripts/search.py \
  --show 1
```

### 3.3 按条件过滤
```bash
# 按日期范围
--date-range "2026-01-01,2026-01-18"

# 按项目路径
--project "/Users/.../memory_siklls"

# 只搜索技能
--type skill

# 只搜索对话
--type conversation
```

---

## 四、搜索范围

| 来源 | 内容 | 匹配字段 |
|------|------|---------|
| 对话归档 | `.agent/memory/conversations/` + SQLite | 标题、首句 |
| 经验沉淀 | `~/.gemini/skills/` | name、description |
| 项目技能 | `<项目>/.agent/skills/` | name、description |

---

## 五、模型管理

- **模型位置**：`~/.gemini/models/all-MiniLM-L6-v2/`
- **首次下载**：约 80MB，自动完成
- **离线使用**：下载后可离线运行

---

## 六、相关脚本

| 脚本 | 功能 |
|------|------|
| `scripts/search.py` | 语义搜索 + 原文展示 |

---

*Created: 2026-01-18*
