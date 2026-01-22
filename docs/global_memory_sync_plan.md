# 全局记忆同步方案 (Git)

## 目标描述
目标是实现“全局记忆”（存储在 `~/.gemini/antigravity/skills` 中的 Agent Skills）在多台终端/电脑之间的同步。鉴于这些内容都是 Markdown/YAML 文本文件，**Git** 是最佳解决方案，因为它提供了版本控制、冲突解决机制，且通用性强。

本计划包含以下步骤：
1.  在全局技能目录初始化 Git 仓库。
2.  配置 `.gitignore` 以防止敏感数据泄露。
3.  建立同步工作流（Push/Pull），需配合私有远程仓库。

## 用户审查事项
> [!IMPORTANT]
> **需要私有仓库**：你需要一个私有 Git 仓库（如 GitHub Private Repo, GitLab, 或自建服务器）作为同步中心。
> **敏感数据**：必须通过 `.gitignore` 严格排除 `secrets.env` 或类似敏感文件，防止凭证上传。

## 拟定变更

### 全局技能目录 (`~/.gemini/antigravity/skills`)

#### [新增] `.gitignore`
创建 `.gitignore` 文件以排除系统文件和密钥。
```gitignore
.DS_Store
*.log
secrets.env
tmp/
```

#### [动作] Git 初始化
运行命令初始化仓库：
```bash
cd ~/.gemini/antigravity/skills
git init
git add .
git commit -m "Initial commit of global skills"
# 用户后续需手动添加远程仓库：
# git remote add origin <你的私有仓库地址>
# git push -u origin main
```

## 验证计划

### 手动验证
1.  **检查状态**：在 `~/.gemini/antigravity/skills` 运行 `git status`，确保仓库已建立且忽略规则生效。
2.  **模拟同步**：
    *   创建一个测试文件。
    *   提交更改。
    *   验证流程是否符合预期。
3.  **跨终端测试 (需用户操作)**：
    *   用户在另一台机器上 clone 该仓库。
    *   验证文件是否同步出现。
