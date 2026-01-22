---
description: 提交代码到开发仓库
---

## 日常开发提交流程

1. 查看当前状态
```bash
git status
```

2. 添加所有更改
```bash
git add .
```

3. 提交更改
```bash
git commit -m "提交信息"
```

4. 推送到开发仓库
// turbo
```bash
git push dev main
```

## 快捷命令

一键提交并推送：
// turbo-all
```bash
git add . && git commit -m "update" && git push dev main
```
