# Claude Code Agent Skills 官方文档总结

> 来源: [official documentation](https://code.claude.com/docs/en/skills)

## 1. 核心概念

Agent Skills 是扩展 Claude 功能的可复用知识包。它们存在于文件系统中，由 Agent 根据任务需求自动发现和加载。

- **目的**: 为 Agent 提供特定任务的指令、最佳实践和工具及其限制。
- **区别**: 
  - **Tools**: 是可执行的代码（函数）。
  - **Skills**: 是指导 AI 如何使用工具和解决问题的"知识"与"流程"。

## 2. 存储位置

- **全局 Skills**: `~/.claude/skills/` (用户级，跨项目可用)
- **项目 Skills**: `.claude/skills/` (项目级，跟随 git 仓库分发)
- **自动发现**: Agent 会递归扫描这些目录。

## 3. 结构与格式

一个 Skill 通常是一个文件夹，核心是 `SKILL.md` 文件。

### 3.1 目录结构示例
```text
my-skill/
├── SKILL.md      (必需：入口与描述)
├── reference.md  (可选：详细参考文档)
└── scripts/      (可选：辅助脚本)
    └── helper.py
```

### 3.2 SKILL.md 格式
必须包含 YAML Frontmatter：
```markdown
---
name: my-skill-name
description: 简短描述这个技能做什么，以及何时应该被触发（非常重要，用于语义匹配）。
allowed-tools: [Read, Bash]  # 可选：权限控制
context: fork                # 可选：在独立上下文中运行
user-invocable: true         # 可选：是否允许用户通过 /name 调用
---

# Skill Name

## Instructions
详细的步骤说明...

## Examples
示例...
```

## 4. 关键特性

### 4.1 渐进式披露 (Progressive Disclosure)
- **描述扫描**: 启动时 Agent 只读取 `description`。
- **按需加载**: 只有当任务匹配描述时，才读取 `SKILL.md` 的正文。
- **深度加载**: 像 `reference.md` 这样的辅助文件，只有在 `SKILL.md` 明确引用且确实需要时才会被读取。

### 4.2 权限控制 (Allowed Tools)
可以限制该 Skill 执行期间能使用的工具，提高安全性。
```yaml
allowed-tools:
  - Read
  - Grep
```

### 4.3 钩子 (Hooks)
支持 `PreToolUse`, `PostToolUse`, `Stop` 等生命周期钩子，用于执行安全检查或审计。

## 5. 最佳实践
- **独立的上下文**: 使用 `context: fork` 来避免复杂任务污染主会话上下文。
- **清晰的描述**: `description` 决定了召回准确率，应包含触发关键词。
- **原子化**: 一个 Skill 解决一类特定问题。
