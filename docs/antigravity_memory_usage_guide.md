# Antigravity 记忆系统使用指南

> 基于官方文档和网络调研整理
> 更新日期：2026-01-17

---

## 一、Antigravity 的三层记忆机制

| 机制 | 类型 | 位置 | 说明 |
|------|------|------|------|
| **Conversation History** | 自动 | 设置中开启 | Agent 可访问过去 20 个对话的摘要 |
| **Knowledge Items** | 自动 | Agent Manager 中查看 | 自动捕获对话中的洞察、模式、解决方案 |
| **Rules / Skills / Workflows** | 手动 | 文件系统 | 用户主动定义的知识和行为规则 |

---

## 二、Knowledge Items（自动记忆）

### 2.1 是什么
- Antigravity 的**持久化记忆系统**
- 自动从对话中提取并组织重要信息
- 包含：标题、摘要、相关文档、代码示例、用户指令

### 2.2 如何工作
1. Agent 与用户对话
2. Antigravity 后台分析对话内容
3. 提取高价值信息 → 创建/更新 Knowledge Item
4. 下次对话时，Agent 自动引用相关 Knowledge Items

### 2.3 在哪里查看
- **Agent Manager** 中可以查看所有 Knowledge Items
- 打开方式：点击左上角头像 → Agent Manager（或使用快捷键）

### 2.4 已知问题
- 有用户反馈：Agent 不总是自动生成 Knowledge Items
- 可能需要**显式指令**让 Agent 保存信息

### 2.5 触发保存的方式（待验证）
尝试对 Agent 说：
- "请把这个方案保存到 Knowledge Items"
- "记住这个解决方案"
- "Save this to knowledge"

---

## 三、手动记忆机制

### 3.1 Rules（规则文件）

| 作用域 | 路径 | 说明 |
|-------|------|------|
| 全局 | `~/.gemini/GEMINI.md` | 所有项目共享的规则 |
| 项目级 | `.agent/rules/` | 仅当前项目生效 |

适合存储：
- 编码风格偏好
- 禁止的行为（如不要全局安装）
- 常用工作流约定

### 3.2 Skills（技能）

| 作用域 | 路径 |
|-------|------|
| 全局 | `~/.gemini/antigravity/skills/` |
| 项目级 | `<workspace>/.agent/skills/` |

特点：
- 按需加载（只在相关时激活）
- 可包含脚本（Python/Bash）
- 适合封装可复用的解决方案

### 3.3 Workflows（工作流）

- 保存的提示词/步骤集合
- 通过斜杠命令触发（如 `/generate-tests`）
- 相当于 Agent 的"宏命令"

---

## 四、你当前的配置状态

根据设置截图：

| 设置 | 状态 |
|------|------|
| Conversation History | ✅ 已开启 |
| Knowledge | ✅ 已开启 |
| Auto-Continue | ❌ 关闭 |
| Agent Auto-Fix Lints | ✅ 已开启 |

---

## 五、下一步建议

1. **查看 Agent Manager** — 看看已有哪些 Knowledge Items
2. **尝试显式保存** — 让 Agent 把当前知识保存到 Knowledge Items
3. **继续使用 Skills** — 作为手动版"知识沉淀"的补充

---

## 六、待解答问题

- [ ] Agent Manager 中能否手动创建/编辑 Knowledge Items？
- [ ] Knowledge Items 存储在哪个目录？（可能是 `~/.gemini/antigravity/implicit/`）
- [ ] 如何让 Agent 更频繁地自动生成 Knowledge Items？
