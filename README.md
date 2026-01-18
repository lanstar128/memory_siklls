# 🧠 AI Memory Skills (AI 记忆技能包)

> **让你的 AI 编程助手拥有"长期记忆"，越用越懂你。**
> 
> *告别"阅后即焚"的对话，将每一次调试、每一个方案沉淀为永久的技能。*

![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)
![Platform](https://img.shields.io/badge/platform-Gemini%20%7C%20Claude%20%7C%20Codex%20%7C%20iFlow-success)

## 😫 你是否遇到过这些痛点？

- **会话失忆**：新开一个 Chat，AI 就忘了上次你是怎么解决那个报错的，你必须把 Log 再贴一遍。
- **重复劳动**：同一个环境配置问题，你给 AI 解释了三遍，它还是如果不根据你的习惯来写。
- **经验流失**：花了一下午调试出的复杂方案，关掉 IDE 就再也找不到了。
- **多端割裂**：家里电脑调好的 Prompt 和习惯，到了公司电脑又要重新调教。

**AI Memory Skills** 正是为此而生。它基于 [Agent Skills](https://agentskills.io) 开放标准，为你的 AI 终端（Gemini CLI, Claude Code, OpenAI Codex 等）外挂一个**持久化、可同步、能成长**的大脑。

---

## ✨ 核心价值

### 1. 🔍 语义级记忆回溯 (Memory Recall)
不再依赖模糊的关键词。即使你忘了具体的函数名，只需说：
> "我们上周讨论过关于 Redis 连接池的优化方案吗？"
> "上次那个 Docker 权限报错是怎么解决的？"

AI 会通过本地向量检索（Semantic Search），精准找到当时的对话现场，并**直接展示原文**，拒绝幻觉。

### 2. 💎 自动化经验沉淀 (Knowledge Deposit)
这不是简单的日志保存。当你完成一个艰难的任务后，AI 会自动评估：
> "检测到本次任务经历了多次试错，是否将解决方案沉淀为**通用技能**？"

通过交互式引导，将一次性的 `Conversation` 转化为可复用的 `Skill`。下次遇到类似问题，AI 会**自动激活**该技能，直接给出最佳实践，避免重蹈覆辙。

### 3. 📂 智能对话归档 (Conversation Archive)
解决 IDE 历史记录混乱的问题。
- **自动触发**：当你表现出结束意图（"提交代码吧"、"今天就到这"）时，AI 主动提醒归档。
- **时间戳注入**：弥补 Markdown 导出丢失时间信息的缺陷，自动注入精准时间戳。
- **去重合并**：同一对话多次导出？自动识别并合并增量内容，保持记忆库整洁。

### 4. ☁️ 全局记忆同步 (Memory Sync)
基于 Git 的私有化同步方案。
- **数据自主**：所有记忆保存在你自己的私有仓库（如 GitHub Private Repo）。
- **多端一致**：`push` / `pull` 一键同步，任何设备上的 AI 都能继承你的所有经验。

---

## � 快速开始

### 一键安装

支持 **macOS / Linux**。脚本会自动检测你的 AI 终端环境（Gemini/Claude/Codex）并安装到正确位置。

```bash
curl -fsSL https://raw.githubusercontent.com/lanstar128/memory_siklls/main/install.sh | bash
```

### 使用场景演示

#### 场景一：保存一下
> **你**: "今天工作完成了，帮我保存一下对话。"
> **AI**: "好的，请点击 Export 导出。已检测到新文件，正在注入时间戳并归档到全局记忆库..."

#### 场景二：由于之前踩过坑...
> **你**: "我要部署这套代码，注意一下端口问题，我们之前踩过坑。"
> **AI**: (自动调用 memory-recall) "正在检索...找到了！在 1 月 15 日的对话中，我们发现 8080 端口被冲突，当时决定统一使用 3000 端口。我会按照这个经验生成部署脚本。"

#### 场景三：同步到新电脑
> **你**: "初始化同步"
> **AI**: "请提供你的 Git 仓库地址...同步完成！已拉取 52 个历史技能和 128 场对话记录。我现在已经熟悉你的所有项目习惯了。"

---

## 🌐 支持平台

本技能包完全遵循 `Agent Skills` 规范，支持所有兼容该标准的 AI 终端：

| 平台 | 兼容性 | 说明 |
|------|-------|------|
| **Gemini CLI** | ⭐ Perfect | 原生开发环境，体验最佳 |
| **Claude Code** | ⭐ Perfect | 完美支持技能调用 |
| **OpenAI Codex** | ⭐ Perfect | 支持标准 Agent 协议 |
| **iFlow CLI** | ✅ Good | 通过 SubAgent 兼容 |

---

## �️ 目录结构

安装后，你的记忆库将位于 `~/.gemini/` (或对应的平台目录)：

```text
~/.gemini/
├── skills/                     # 你的技能库 (如同 AI 的"肌肉记忆")
│   ├── conversation-archive/
│   ├── memory-recall/
│   └── ...
├── memory/
│   ├── conversations/          # 你的对话仓库 (如同 AI 的"海马体")
│   └── conversations.db        # 向量索引数据库
└── GEMINI.md                   # 全局指令
```

---

## 📋 可选依赖

为了体验极致的语义搜索（Memory Recall），建议安装 Python 依赖（安装脚本会提示）：

```bash
pip3 install sentence-transformers
```
*(如果不安装，将降级为普通关键词搜索，依然可用)*

---

**开源协议**: Apache 2.0
**项目地址**: [https://github.com/lanstar128/memory_siklls](https://github.com/lanstar128/memory_siklls)
