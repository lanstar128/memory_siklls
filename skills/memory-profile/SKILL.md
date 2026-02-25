---
name: memory-profile
description: |
  长期偏好与项目交接记忆技能。用于记录用户稳定偏好、协作风格、项目约束、阶段进展和下次接续点。
  触发条件：用户说“记住这个偏好/约定”“下次接着做”“别让我重复交代”“记录当前状态”。
compatibility: Antigravity IDE, Claude Code, Gemini CLI, OpenAI Codex, iFlow CLI
metadata:
  author: lanstar128
  version: "1.0"
---

# 长期偏好与项目交接记忆技能

这个技能用于补齐“全局记忆”里最实用的一部分：**用户偏好**和**项目接力状态**。

## 一、存储位置（默认）

| 文件 | 作用 |
|------|------|
| `~/.ai-memory/data/profiles/user-profile.md` | 用户长期偏好（语言、表达、代码风格、禁忌） |
| `~/.ai-memory/data/projects/<项目名>/handoff.md` | 当前项目交接状态（完成/未完成/下一步） |
| `~/.ai-memory/data/projects/<项目名>/decisions.md` | 关键决策与理由 |

> `<项目名>` 建议使用项目目录名（如 `new-project`）。

## 二、什么时候使用

- 用户重复强调同一偏好（如“以后都用中文”“简洁回复”）
- 本次会话形成了关键约束或长期约定
- 结束前需要保存进度，下次继续
- 需要记录“为什么这样做”的决策依据

## 三、推荐流程

### 3.1 会话开始（读取）

1. 读取 `user-profile.md`（如果存在）
2. 读取当前项目 `handoff.md`（如果存在）
3. 用一句话确认关键约束后开始执行

### 3.2 会话中（更新）

仅写入“稳定信息”：
- 用户偏好（语言、输出风格、代码偏好）
- 项目约束（版本、平台、目录结构、不可改动项）
- 关键决策（方案选择 + 原因）

### 3.3 会话结束（交接）

更新当前项目 `handoff.md`：
- 当前目标
- 已完成
- 未完成
- 下一步（尽量写到命令/文件级别）
- 阻塞项

## 四、模板（可直接创建）

### `user-profile.md`

```md
# User Profile

- Language: 中文
- Communication style: 简洁、直接、先结论后细节
- Coding preferences:
- Review priorities:
- Repeated constraints:
- Updated: 2026-02-25
```

### `handoff.md`

```md
# Handoff

- Date: 2026-02-25
- Project:
- Current goal:
- Completed:
- In progress:
- Next step:
- Blockers:
- Key files:
```

### `decisions.md`

```md
# Decisions

## 2026-02-25
- Decision:
- Rationale:
- Impact:
```

## 五、注意事项

- 不记录密码、密钥、Token
- 保持短小、可检索
- 优先更新已有条目，避免重复堆积

