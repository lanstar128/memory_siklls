# AI Memory Skills

基于 Agent Skills 的 AI 记忆系统，解决 AI 会话失忆问题。

## 核心功能

| 技能 | 功能 | 触发方式 |
|------|------|---------|
| **conversation-archive** | 归档对话记录，注入时间戳 | 说"保存对话"或检测到离开意图 |
| **memory-recall** | 检索历史对话，支持语义搜索 | 说"我们之前讨论过..." |
| **memory-sync** | 同步记忆到远程 Git 仓库 | 说"同步记忆"/"备份技能" |
| **knowledge-deposit** | 沉淀解决方案为可复用技能 | 任务结束时自动评估 |

## 全局技能位置

技能安装到 `~/.gemini/skills/`：

```
~/.gemini/
├── .git/                       # Git 仓库（同步用）
├── GEMINI.md                   # 全局规则
├── secrets.env                 # 敏感配置
├── skills/                     # 全局技能库 (安装位置)
│   ├── conversation-archive/   # 对话归档
│   ├── memory-recall/          # 记忆检索
│   ├── memory-sync/            # 记忆同步
│   └── knowledge-deposit/      # 经验沉淀
└── memory/
    ├── conversations/          # 对话原文
    ├── conversations.db        # SQLite 索引
    └── index_backup.json
```

## 使用方法

### 归档对话
1. 完成工作后说"保存对话"或"归档一下"
2. 按提示点击 IDE 的 Export 按钮
3. 说"导出好了"
4. AI 自动处理：注入时间戳 → 保存到全局目录 → 更新索引 → 自动同步

### 检索历史
- 说"我们之前讨论过什么"或"上次怎么解决的"
- AI 搜索历史对话和技能，展示结果列表
- 选择后直接显示原文（不经 AI 处理）

### 经验沉淀
- 任务完成后，AI 自动评估是否值得沉淀
- 满足条件时询问用户确认
- 保存为可复用的技能文件

## 技术实现

| 组件 | 技术 |
|------|------|
| 时间戳来源 | `ADDITIONAL_METADATA.current local time` |
| 对话存储 | 全局存储 (`~/.gemini/memory/conversations/`) |
| 全局索引 | SQLite (`~/.gemini/memory/conversations.db`) |
| 语义搜索 | `sentence-transformers` (可选) |

## 安装

1. 将全局技能复制到 `~/.gemini/skills/`
2. 将 `GEMINI.md` 合并到 `~/.gemini/GEMINI.md`
3. 可选：安装语义搜索依赖 `pip install sentence-transformers`



---
*Created: 2026-01-18*
