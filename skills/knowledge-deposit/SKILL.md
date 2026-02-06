---
name: knowledge-deposit
description: |
  经验沉淀技能。在任务成功完成后，评估是否需要将解决方案保存为可复用的技能。
  触发条件：任务结束时、用户说"记住这个"/"保存这个"、解决问题过程有试错。
compatibility: Antigravity IDE, Claude Code, Gemini CLI, OpenAI Codex, iFlow CLI
metadata:
  author: lanstar128
  version: "2.0"
---

# 经验沉淀技能

将有价值的解决方案沉淀为可复用的知识或技能。

## 一、路径配置

| 变量 | 路径 | 说明 |
|------|------|------|
| `DATA_DIR` | `~/.ai-memory/data` | 私人数据目录 |
| `KNOWLEDGE_DIR` | `~/.ai-memory/data/knowledge` | 知识沉淀目录 |
| `SKILLS_DIR` | `~/.ai-memory/skills/skills` | 技能目录（只读） |

> **注意**：用户个人的知识沉淀保存到 `KNOWLEDGE_DIR`，而非 `SKILLS_DIR`。
> `SKILLS_DIR` 是公开仓库，由维护者管理。

---

## 二、沉淀评估

### 触发条件（满足任意一条）

| 条件 | 检测方式 |
|-----|---------| 
| 经历试错 | 任务过程中有失败→调整→成功 |
| 调试耗时 | 对话来回超过 5 轮 |
| 非常规解法 | 使用了项目特有的方案 |
| 用户主动要求 | 用户说"记住这个"、"保存" |

### 不沉淀条件

| 条件 | 说明 |
|-----|------|
| 一次成功 | 直接成功，无试错 |
| 临时操作 | 明确只是这一次的处理 |
| 敏感信息 | 包含密码、密钥 |

---

## 三、沉淀流程

```
评估 → 信息提取 → 用户确认 → 保存文件
```

### 3.1 保存到知识目录

```bash
KNOWLEDGE_DIR=~/.ai-memory/data/knowledge

cat > $KNOWLEDGE_DIR/<主题>.md << 'EOF'
---
title: <标题>
date: $(date +%Y-%m-%d)
tags: [标签1, 标签2]
---

# <问题标题>

## 问题现象
<描述>

## 解决方案
1. <步骤一>
2. <步骤二>

## 相关文件
- <文件路径>
EOF
```

---

## 四、确认完成

```
✅ 知识已沉淀

位置: ~/.ai-memory/data/knowledge/<主题>.md
下次检索时可以找到这个解决方案。
```

---

*Last Updated: 2026-02-06*
