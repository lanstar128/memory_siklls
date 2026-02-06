# 🧠 AI Memory System (AMS)

> **为你的 AI 助手（Gemini, Claude, ChatGPT 等）构建一个持久的、跨平台的、隐私优先的"第二大脑"。**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](http://makeapullrequest.com)

**AI Memory System (AMS)** 是一个开源的 AI 记忆管理框架。它通过标准化的文件结构和 Git 自动同步机制，让不同的 AI 工具共享同一份记忆（对话归档、知识库、偏好设置），并支持在 macOS, Windows, Linux, Android (Termux) 等多设备间无缝流转。

---

## 🌟 核心特性

- **🔒 隐私优先 (Privacy First)**
  - 采用 **"Code (Public) + Data (Private)" 双仓库架构**。
  - 你的记忆数据（`conversations`, `knowledge`, `secrets`）只存储在你私有的 GitHub 仓库中，绝不公开。
  - 技能代码开源，共享社区智慧。

- **⚡️ 智能聚合 (Smart Aggregation)**
  - **Auto-Merge**: 自动聚合官方技能和你独有的私有技能。
  - **Priority Override**: 官方核心技能更新自动覆盖旧版，确保系统稳定，但也允许你保留独家定制的 Private Skills。

- **🚀 跨平台 & 跨工具 (Cross-Platform)**
  - **OS**: macOS, Linux, Windows, Android (Termux)。
  - **AI Tools**: 原生支持 Gemini CLI, Claude Code, Antigravity IDE, iFlow, Codex 等。
  - **IDE**: 提供 VS Code / Cursor / JetBrains 配置指南。

- **🔄 无感同步 (Seamless Sync)**
  - 一个命令 `同步记忆` 即可完成 `pull -> commit -> push` 全流程。
  - 自动处理多设备冲突，记录变更设备来源。

---

## 📦 快速开始

### 1. 准备工作
在 GitHub 上创建一个 **私有仓库 (Private Repository)**，命名为 `my-ai-memory` (或者其他你喜欢的名字)。
> 这个仓库将用来存放你的私人数据。

### 2. 一键安装
在终端运行以下命令（支持 mac/linux/termux/win-git-bash）：

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

我们非常欢迎社区贡献！如果你有通用的 AI 技能（如"抓取网页"、"生成图表"、"管理待办"等），请贡献到 `skills/` 目录。

1. Fork 本仓库
2. 创建你的技能目录 `skills/your-skill-name`
3. 编写 `SKILLS.md` 和代码
4. 提交 Pull Request

让我们的 AI 变得更强大！

---

## 📜 许可证

MIT License © 2024 [Lanstar128](https://github.com/lanstar128)
