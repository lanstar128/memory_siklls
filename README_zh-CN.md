# 🧠 AI Memory System (AMS)

<div align="center">

**为你的 AI 助手（Gemini, Claude, ChatGPT 等）构建一个持久的、跨平台的、隐私优先的"第二大脑"。**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](http://makeapullrequest.com)

[English](./README.md) | [简体中文](./README_zh-CN.md)

</div>

**AI Memory System (AMS)** 是一个专为 **Antigravity, Claude Code, Gemini CLI, Open Interpreter, iFlow** 等终端 AI 工具打造的 **全局记忆层**。

### 🚨 痛点：AI 记忆的碎片化孤岛
但在当下，我们在使用各种本地开发工具（Terminal / IDE）与 AI 结对编程时，面临一个巨大的痛点：
- **记忆割裂**：你在 MacBook 上教给 AI 的项目知识，切到 Windows 或 Android Termux 上全忘了。
- **经验流失**：你解决过一次的复杂报错，换个环境又得重头排查一遍，无法沉淀经验。
- **上下文丢失**：AI 不知道你的编码偏好，不知道你上周在另一台设备上讨论的架构设计。

**AMS 就是为了完美解决这个问题而生。** 它让你的所有 AI 工具共享同一个"大脑"，确保你的知识、经验和上下文在所有设备间实时同步。

---

## 🌟 核心价值

- **🧠 全局记忆 (Global Memory)**
  - **打破设备壁垒**：无论你在 Mac 终端、Windows Git Bash 还是安卓手机 Termux 上开发，AI 都能读取到同一份沉淀下来的知识。
  - **一次解决，处处复用**：当 AI 帮你解决了一个棘手 Bug，这段经验会被归档。下次在任何设备遇到相同问题，AI 能立即调取之前的解决方案。

- **💎 经验晶体 (Experience Crystallization)**
  - **知识沉淀**：不只是简单的保存对话，而是将零散的对话转化为结构化的**知识晶体**（Markdwon/代码片段）。
  - **伴随式成长**：你的 AI 助手会随着你的使用越来越懂你，越来越懂你的项目，而不是每次重置为空白。

- **🛡️ 隐私安全可控 (Privacy Control)**
  - **Code (Public) + Data (Private)**：所有记忆数据存储在你私有的 GitHub 仓库。
  - **数据主权**：你完全掌控自己的数据，不依赖任何厂商的云端存储，安全、透明、可控。

- **⚡️ 跨端无缝接力 (Seamless Relay)**
  - **工作流接力**：在公司电脑上没写完的代码逻辑，同步记忆后，回家路上用手机 Termux 继续无缝对话。
  - **智能聚合**：自动聚合官方最新技能和你独有的私有配置，既享受社区更新，又保留个性化定制。

---

## 📦 快速开始

### 1. 准备工作
在 GitHub 上创建一个 **私有仓库 (Private Repository)**，命名为 `my-ai-memory` (或者其他你喜欢的名字)。
> 这个仓库将用来存放你的私人数据，请务必设为私有！

### 2. 一键安装
在终端运行以下命令（支持 Mac / Linux / Windows / Termux）：

```bash
curl -sSL https://raw.githubusercontent.com/lanstar128/AI_memory_siklls/main/install.sh | bash
```

**安装脚本会自动执行：**
1. 检测系统环境 (OS, Git, SSH)。
2. 拉取官方技能库 (`~/.ai-memory/skills`)。
3. 引导你克隆私人数据仓库到 `~/.ai-memory/data`。
4. 自动配置 Git 授权 (支持 SSH 密钥或 GitHub CLI 网页登录)。
5. 创建智能聚合目录 `~/.ai-memory/current_skills`。
6. 为已安装的 AI 工具创建符号链接。

---

## 🛠 使用指南

安装完成后，你可以直接在 AI 工具（如 Gemini）中使用自然语言触发技能：

### 基础指令

| 你说... | 触发技能 | 说明 |
|---------|---------|------|
| **"同步记忆"** | `memory-sync` | 将本地变更推送到你的私有仓库 |
| **"拉取记忆"** | `memory-sync` | 从远程拉取最新的记忆数据 |
| **"更新技能"** | `memory-sync` | 获取本仓库的最新代码更新 |
| **"保存对话"** | `conversation-archive` | 将当前上下文归档保存 |
| **"检索记忆 [关键词]"** | `memory-recall` | 搜索所有归档和知识库 |

### 目录结构

系统会在你的主目录下创建 `~/.ai-memory`：

```text
~/.ai-memory/
├── 📂 skills/          # [Public] 官方技能代码 (本仓库)
├── 📂 data/            # [Private] 你的私人数据仓库
│   ├── 📂 conversations/ # 对话历史归档
│   ├── 📂 knowledge/     # 沉淀的结构化知识
│   └── 📂 skills/        # (可选) 你独有的私有技能
├── 📂 current_skills/  # [Auto] 运行时聚合目录 (Public + Private)
└── 📂 models/          # 本地 Embedding 模型缓存
```

---

## 🤝 参与贡献

我们欢迎社区贡献者帮助扩展记忆系统的核心能力！这不仅仅是一堆脚本的集合，而是 AI 认知的基础层。

我们急需以下方向的贡献：
- **记忆适配器 (Memory Adaptors)**：支持 Vector DB (Pinecone, Milvus) 或 Graph DB (Neo4j)。
- **检索策略 (Retrieval Strategies)**：实现 Advanced RAG、混合检索或重排序 (Re-ranking) 算法。
- **工具集成 (Tool Integrations)**：开发 VS Code、JetBrains 插件或浏览器扩展。
- **隐私核心 (Privacy Core)**：增强本地加密和零知识同步协议。

Fork -> Branch -> PR。让我们一起构建 AI 记忆的未来。

## 🔮 未来规划 (Roadmap)

### 5.1 记忆分层 (Memory Hierarchy)
目前所有记忆都是"长期"的。未来将引入更精细的生命周期管理：
- **Conversation Memory**: 会话级，退出即丢弃
- **Session Memory**: 任务级，完成后归档或丢弃
- **User Memory**: 长期，存储用户偏好与习惯
- **Skill Memory**: 永久，沉淀可复用的知识与技能

### 5.2 动态遗忘机制 (Dynamic Forgetting)
模拟大脑的遗忘机制，保持记忆库的高效：
- **相关度衰减**: 长期未访问的记忆降低检索权重
- **定期清理**: 提供 `memory-prune` 技能清理过期或低价值内容

### 5.3 增强检索能力 (Enhanced Retrieval)
- **图结构关联**: 记录记忆点之间的引用关系，构建知识图谱
- **时间感知**: 检索时融合"最近优先"策略
- **多模态支持**: 支持图片、代码片段的 Embedding 索引

### 5.4 用户偏好记忆 (User Preferences)
建立显式的用户画像系统：
- **编码风格**: 如 "偏好 TypeScript", "注释简洁"
- **工作习惯**: 如 "工作时间 9-12 点", "喜欢深色模式"

---

## 📜 许可证

MIT License © 2024 [Lanstar128](https://github.com/lanstar128)
