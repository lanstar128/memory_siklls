# 记忆系统实施计划

> **目标**: 在 Google Antigravity 中实施基于 Agent Skills 的记忆系统
> **创建日期**: 2026-01-16

---

## 一、环境信息

根据联网研究，Antigravity 的 Skills 目录结构：

| 作用域 | 路径 | 说明 |
|-------|------|------|
| **全局** | `~/.gemini/antigravity/skills/` | 所有项目共享 |
| **项目级** | `<workspace>/.agent/skills/` | 仅当前项目 |

---

## 二、实施步骤

### 阶段一：基础设施搭建

#### 步骤 1：创建全局技能目录
```bash
mkdir -p ~/.gemini/antigravity/skills/user-profile
mkdir -p ~/.gemini/antigravity/skills/problem-solutions
```

#### 步骤 2：创建敏感信息文件
```bash
touch ~/.gemini/secrets.env
```

#### 步骤 3：创建元数据文件（用于阈值统计）
```bash
echo '{"threshold": 0.3, "skill_count": 0, "confirmation_rate": 0}' > ~/.gemini/meta.json
```

---

### 阶段二：核心技能创建

#### 步骤 4：创建用户档案技能

创建文件 `~/.gemini/antigravity/skills/user-profile/SKILL.md`：

```yaml
---
name: user-profile
description: |
  用户个人档案，包含身份信息、偏好设置、常用项目。
  每次新会话开始时自动激活，帮助 AI 了解用户背景。
---

# 用户档案

## 基本信息
- 用户名: lanstar
- 系统: macOS (256GB 存储空间，需节省磁盘)
- 常用语言: 中文
- 代码风格: 简洁实用

## 偏好设置
- 不要全局安装 (npm -g, pip)
- 优先使用本地依赖
- 错误后停止，不自动重试
- 不要幻觉/瞎编

## 活跃项目
1. 懒爱瘦 - 减肥产品 Android + Web + Server
2. 智剪大师 - 视频剪辑软件
```

---

### 阶段三：更新用户规则

#### 步骤 5：更新 GEMINI.md 添加沉淀规则

在现有的 `~/.gemini/GEMINI.md` 中添加以下内容：

```markdown
## 经验沉淀协议

### 沉淀触发条件（满足任意一条）
- 任务过程中有失败→调整→成功的过程
- 解决问题花费了多个来回
- 使用了项目特有的方案或变通方法
- 用户主动要求（说"记住这个"、"以后都这样做"）

### 不沉淀条件（满足任意一条）
- 直接成功，无试错过程
- 明确只是这一次的特殊处理
- 包含 secrets.env 中的实际敏感值

### 沉淀流程
1. 任务结束后自动评估是否满足沉淀条件
2. 如满足条件，向用户提议沉淀
3. 用户确认后，创建/更新技能文件到 ~/.gemini/antigravity/skills/

### 敏感信息规则
- 禁止将 secrets.env 中的实际值写入任何技能文件
- 技能文件中使用 ${描述} 形式引用（如 ${小米路由器密码}）
- secrets.env 文件使用自然语言格式书写，无需 KEY=VALUE
```

---

### 阶段四：验证测试

#### 步骤 6：验证技能加载

1. 重启 Antigravity
2. 开始新会话
3. 询问：「你知道我是谁吗？」
4. 预期：AI 应该能识别用户信息

#### 步骤 7：验证沉淀流程

1. 执行一个需要调试的任务（例如故意制造一个 Bug 然后解决）
2. 任务完成后观察 AI 是否提议沉淀
3. 确认沉淀后检查 `~/.gemini/antigravity/skills/` 是否有新文件

---

## 三、文件清单

| 文件 | 用途 | 需创建 |
|-----|------|--------|
| `~/.gemini/antigravity/skills/user-profile/SKILL.md` | 用户档案 | ✅ |
| `~/.gemini/secrets.env` | 敏感信息存储 | ✅ |
| `~/.gemini/meta.json` | 阈值和统计元数据 | ✅ |
| `~/.gemini/GEMINI.md` | 用户规则（更新） | 修改 |

---

## 四、注意事项

1. **路径差异**: Antigravity 使用 `~/.gemini/antigravity/skills/` 而非方案文档中的 `~/.gemini/skills/`
2. **项目级技能**: 如果某些技能只属于特定项目，应放在 `<project>/.agent/skills/`
3. **Git 同步**: 全局技能目录可以用 Git 管理，方便备份和跨设备同步

---

## 五、后续扩展

- [ ] 创建更多专项技能（Android、Firebase、NodeJS 等）
- [ ] 积累 5-10 个沉淀技能后评估阈值效果
- [ ] 考虑是否需要 MCP 集成（更复杂的工具调用）
