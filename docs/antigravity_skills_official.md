# Antigravity Agent Skills 官方文档总结

> 来源: Antigravity 官方搜索资料与介绍

## 1. 核心定位

Antigravity 是 Google DeepMind 推出的 Agent-first 开发环境。Agent Skills 是其核心组件，旨在让开发者通过可复用的知识包来扩展 Agent 的能力。

## 2. 关键特性

- **标准化接口**: Skills 作为开放标准，通过 `SKILL.md` 定义。
- **任务导向**: 旨在解决特定开发任务（如代码审查、错误修复、重构）。
- **多表面集成 (Multi-Surface)**: Skills 可以跨编辑器、终端和浏览器协调 Agent 的行动。
- **Artifacts (交付物)**: 强调操作的可验证性，生成任务清单、实施计划和测试结果等具体产物。

## 3. 工作流集成

1. **识别**: Agent 识别当前任务意图。
2. **加载**: 自动检测并加载匹配的 Skill。
3. **执行**: Agent 遵循 Skills 定义的流程、检查点和最佳实践执行任务。
4. **验证**: 生成 Verify 阶段的 Artifacts 供用户审查。

## 4. 与 Tools 的区别

与 Claude Code 类似：
- **Skills**: 提供"How-to"的知识和流程指导（例如：如何进行符合 Google 标准的代码审查）。
- **Tools**: 提供"Action"的能力（例如：读取文件、运行命令）。

## 5. 存储与分发

- 支持项目级存储（在项目文件夹中）和全局存储。
- 允许通过版本控制共享 Skills。

## 6. Antigravity 独有特性

- **Artifacts First**: 强调生成结构化的交付物（Artifacts），建立用户信任。
- **Parallel Execution**: 支持并行执行任务测试。
- **Memory & Learning**: 平台层面强调从过去的任务中学习（这一点与我们设计的"经验沉淀"高度契合，但 Antigravity 似乎将其作为平台愿景的一部分）。
