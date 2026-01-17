# AI Memory Skills

基于 Agent Skills 的 AI 记忆系统，用于解决 AI 会话失忆、上下文腐烂、经验孤岛问题。

## 目录结构

```
├── GEMINI.md           # 全局协议（复制到 ~/.gemini/GEMINI.md）
├── skills/             # 全局技能（复制到 ~/.gemini/antigravity/skills/）
│   ├── knowledge-deposit/       # 经验沉淀技能
│   └── xiaomi-shellclash-node-update/  # 路由器节点更新
├── docs/               # 设计文档
└── workflows/          # 工作流模板
```

## 使用方法

1. 将 `GEMINI.md` 复制到 `~/.gemini/GEMINI.md`
2. 将 `skills/` 下的内容复制到 `~/.gemini/antigravity/skills/`
3. 根据需要创建 `~/.gemini/secrets.env` 存放敏感配置

## 技能列表

| 技能 | 说明 |
|-----|------|
| `knowledge-deposit` | 自动评估并沉淀有价值的解决方案 |
| `xiaomi-shellclash-node-update` | 更新小米路由器 ShellClash 节点配置 |
