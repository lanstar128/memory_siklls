# AI Memory System

跨工具、跨设备的 AI 记忆系统。让你的 AI 助手记住过去、学习经验、共享知识。

## 支持的工具

- Gemini CLI / Antigravity IDE
- Claude Code
- OpenAI Codex CLI
- iFlow CLI

## 安装

```bash
curl -sSL https://raw.githubusercontent.com/lanstar128/AI_memory_siklls/main/install.sh | bash
```

安装脚本会：
1. 克隆技能仓库到 `~/.ai-memory/skills/`
2. 询问你的私人数据仓库地址
3. 为已安装的 AI 工具创建符号链接

## 使用

| 触发词 | 功能 |
|-------|------|
| "同步记忆" | 推送本地记忆到远程仓库 |
| "拉取记忆" | 从远程仓库拉取记忆 |
| "保存对话" | 归档当前对话 |
| "记住这个" | 将解决方案沉淀为技能 |
| "上次怎么解决的" | 检索历史记忆 |
| "更新技能" | 更新技能代码到最新版本 |

## 目录结构

```
~/.ai-memory/
├── skills/          ← 技能代码（本仓库）
├── data/            ← 你的私人数据
│   ├── conversations/
│   ├── knowledge/
│   └── secrets.env
└── models/          ← embedding 模型
```

## 技能列表

| 技能 | 功能 |
|------|------|
| `conversation-archive` | 对话归档 |
| `knowledge-deposit` | 经验沉淀 |
| `memory-recall` | 记忆检索 |
| `memory-sync` | 记忆同步 |

## License

MIT
