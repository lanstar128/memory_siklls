# 系统设计对比分析报告

## 1. 核心兼容性分析

### 1.1 路径与结构
- **现状**: 使用 `~/.gemini/antigravity/skills`。
- **官方**: Claude 使用 `~/.claude/skills`，Antigravity 使用项目内或特定配置目录。
- **结论**: ✅ **兼容**。只要 Agent 能够被配置去扫描该目录，路径本身不是硬性限制。为了与 Antigravity 原生体验更一致，建议后续支持项目级 `.agent/skills` 目录。

### 1.2 渐进式披露 (Progressive Disclosure)
- **现状**: 设计中包含了分层加载（Description -> Content -> Scripts）。
- **官方**: Claude Code 原生支持此机制，Antigravity 也采用类似机制。
- **结论**: ✅ **高度一致**。这是 Agent Skills 的核心设计哲学，我们的设计正确抓住了这一点。

### 1.3 SKILL.md 规范
- **现状**: Frontmatter 包含 `name`, `description` (多行)。
- **官方**: 
  - `description` 推荐简短单行，用于高效匹配。
  - 支持 `allowed-tools`, `context: fork` 等高级字段。
- **结论**: ⚠️ **需要优化**。
  - 建议将 `description` 改为**单行摘要**，提高语义匹配效率。
  - 长文本描述移至正文 `Instructions` 部分。
  - 引入 `allowed-tools` 以增强安全性（如只读技能）。

## 2. 差异化与自定义扩展分析

### 2.1 经验自动沉淀 (Experience Deposit)
- **设计**: 系统自动评估任务结果，提议沉淀为新 Skill。
- **官方**: 官方目前视为静态配置，由开发者编写。Antigravity 愿景中提到 "Learning & Knowledge Base"，但未开放全自动机制。
- **结论**: 🌟 **领先特性**。这是我们设计的核心亮点。它是对官方静态 Skill 机制的**动态补充**，不冲突且极具价值。**建议保留并作为核心差异化功能。**

### 2.2 敏感信息管理 (secrets.env)
- **设计**: 使用自然语言 `secrets.env` 和动态变量替换。
- **官方**: 仅支持 `$ARGUMENTS` 和 `${SESSION_ID}`。
- **结论**: ⚠️ **非原生功能**。这是我们通过 Prompt Engineering 实现的"软特性"。
  - **风险**: Agent 可能偶尔忘记读取或替换。
  - **建议**: 在 `GEMINI.md` 的 System Prompt 中通过**强制规则**来固化这一行为，确保稳定性。

### 2.3 语义检索对比
- **设计**: 利用 LLM 语义能力对比 Description 进行去重。
- **官方**: 依赖文件名或手动管理。
- **结论**: ✅ **合理扩展**。利用 LLM 本身的能力管理 Skills 库，符合 Agent-first 的理念。

## 3. 改进建议清单

1. **规范化 Frontmatter**:
   - 将现有 Skills 的 `description` 精简为单行。
   - 补充 `allowed-tools` 字段。

2. **目录结构标准化**:
   - 采用 `skill-name/SKILL.md` 结构，而非散文件。
   - 将复杂逻辑抽离为 `scripts/` (如 Python 验证脚本)。

3. **增强 GEMINI.md**:
   - 显式定义 `secrets.env` 的加载规则（因为这不是引擎原生功能）。
   - 显式定义"沉淀机制"的触发 Prompt。

4. **对齐 Antigravity Artifacts**:
   - 我们的"沉淀"过程本身应该生成一个 Artifact（如 `knowledge_draft.md`），供用户通过 UI 确认，这完全符合 Antigravity 的 "Artifacts & Verification" 哲学。
