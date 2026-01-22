---
name: memory-sync
description: |
  记忆同步技能。将本地技能、对话记录和配置同步到远程 Git 仓库。
  触发条件：用户说"同步记忆"/"备份技能"/"push 记忆"/"拉取记忆"/"恢复技能"。
compatibility: Claude Code, Gemini CLI, OpenAI Codex, iFlow CLI
metadata:
  author: lanstar128
  version: "1.0"
---

# 记忆同步技能

将 `${MEMORY_ROOT}` 下的所有记忆内容同步到远程 Git 仓库。

## 零、确定根目录

AI 应根据当前运行环境确定记忆根目录 (`MEMORY_ROOT`)：

| 环境 | 根目录路径 |
|------|-----------|
| **Antigravity / Gemini CLI** | `~/.gemini/` |
| **Claude Code** | `~/.claude/` |
| **Codex CLI** | `~/.codex/` |
| **iFlow CLI** | `~/.iflow/` |

> 以下指令中的 `${MEMORY_ROOT}` 指代上述路径。

---

## 一、触发条件

| 触发词 | 动作 |
|--------|------|
| "同步记忆" / "备份技能" / "push 记忆" | 推送到远程 |
| "拉取记忆" / "恢复技能" / "pull 记忆" | 从远程拉取 |
| "初始化同步" | 首次设置仓库 |

---

## 二、环境检查

### 2.1 检查 Git 是否可用
```bash
which git
```

如果没有，提示用户安装：
```
brew install git
```

### 2.2 检查仓库是否初始化
```bash
git -C ${MEMORY_ROOT} rev-parse --git-dir 2>/dev/null
```

- 返回 `.git` → 已初始化
- 返回错误 → 需要初始化

---

## 三、首次初始化流程

如果 `${MEMORY_ROOT}` 未初始化 Git：

**步骤 1：创建 .gitignore**
```bash
cat > ${MEMORY_ROOT}/.gitignore << 'EOF'
# 系统文件
.DS_Store
*.log

# IDE 运行时数据
antigravity/brain/
antigravity/conversations/
antigravity/annotations/
antigravity/code_tracker/
antigravity/context_state/
antigravity/implicit/
antigravity/knowledge/
antigravity/installation_id
antigravity/user_settings.pb
antigravity/browserAllowlist.txt
antigravity/mcp_config.json

# 模型缓存
models/
EOF
```

**步骤 2：初始化仓库**
```bash
git -C ${MEMORY_ROOT} init
git -C ${MEMORY_ROOT} add .
git -C ${MEMORY_ROOT} commit -m "Initial: skills and memory"
```

**步骤 3：询问用户远程仓库地址**
```
请提供你的私有 Git 仓库地址（如 GitHub Private Repo）：
```

**步骤 4：关联远程并推送**
```bash
git -C ${MEMORY_ROOT} remote add origin <用户提供的地址>
git -C ${MEMORY_ROOT} branch -M main
git -C ${MEMORY_ROOT} push -u origin main
```

---

## 四、同步操作

> [!CAUTION]
> **必须使用 `git -C ${MEMORY_ROOT}`**，避免和项目仓库冲突！

### 4.1 推送 (Push)
```bash
git -C ${MEMORY_ROOT} add .
git -C ${MEMORY_ROOT} commit -m "sync: $(date '+%Y-%m-%d %H:%M')"
git -C ${MEMORY_ROOT} push
```

### 4.2 拉取 (Pull)
```bash
git -C ${MEMORY_ROOT} pull
```

---

## 五、同步内容

| 目录/文件 | 说明 | 同步 |
|----------|------|------|
| `skills/` | 全局技能 | ✅ |
| `memory/` | 对话记录 + 索引 | ✅ |
| `GEMINI.md` | 全局规则 | ✅ |
| `secrets.env` | 敏感配置 | ✅ |

---

## 六、确认完成

```
✅ 记忆已同步

推送: 3 个文件变更
远程: origin/main
```

---

*Created: 2026-01-18*
