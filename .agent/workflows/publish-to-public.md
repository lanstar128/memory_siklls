---
description: 发布代码到公开仓库
---

## 发布流程

1. 确保所有更改已提交到开发仓库
```bash
git status
```

2. 运行发布脚本
// turbo
```bash
bash scripts/publish-public.sh
```

3. （可选）自定义提交信息
```bash
bash scripts/publish-public.sh "发布新版本 v1.0.0"
```

## 注意事项

- 脚本会自动排除 `.publish-ignore` 中列出的文件
- 确保敏感信息（如 `secrets.env`）已添加到排除列表
- 发布后会自动清理临时文件
