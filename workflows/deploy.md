---
description: 标准部署流程 - 使用Git拉取方式部署到腾讯云
---

# 标准部署流程（Git方式）

## 前提条件

✅ 服务器www用户已配置GitHub SSH密钥
✅ Git仓库使用SSH地址：`git@github.com:lanstar128/jianfei.git`

## 完整部署步骤

### 1. 本地构建
```bash
cd /Volumes/本地e/MyApp/Antigravity-project/jianfei
npm run build && npm run build:admin
```

### 2. 提交到Git
```bash
git add .
git commit -m "feat: 你的提交信息"
git push
```

### 3. 服务器拉取代码

**方式A：拉取当前分支（推荐）**
```bash
# 先查看当前分支
git branch --show-current

# 假设当前分支是 feature/mobile-optimization
ssh tencent "cd /www/wwwroot/jianfei && sudo -u www git fetch origin && sudo -u www git checkout feature/mobile-optimization && sudo -u www git pull origin feature/mobile-optimization && sudo chown -R www:www ."
```

**方式B：拉取 main 分支**
```bash
ssh tencent "cd /www/wwwroot/jianfei && sudo -u www git fetch origin && sudo -u www git checkout main && sudo -u www git pull origin main && sudo chown -R www:www ."
```

> 注意：必须用 `-u www` 因为SSH密钥配置在www用户下

### 4. 重启Node.js服务

登录宝塔面板 → Node项目管理 → 重启 jianfei_api

## 如果遇到问题

### Git仓库未初始化
```bash
# 首次需要初始化（只执行一次）
ssh tencent
cd /www/wwwroot/jianfei
sudo -u www git init
sudo -u www git remote add origin git@github.com:lanstar128/jianfei.git
sudo -u www git fetch origin
sudo -u www git checkout -b main origin/main
```

### 权限问题
```bash
ssh tencent "sudo chown -R www:www /www/wwwroot/jianfei"
```

### 代码冲突（强制覆盖）
```bash
# 替换 BRANCH_NAME 为实际分支名
ssh tencent "cd /www/wwwroot/jianfei && sudo -u www git fetch origin BRANCH_NAME && sudo -u www git reset --hard origin/BRANCH_NAME"
```

## 快速部署命令（一键执行）

```bash
# ⚠️ 需要先确认当前分支，替换 BRANCH_NAME
BRANCH_NAME=$(git branch --show-current) && \
npm run build && npm run build:admin && \
git add . && git commit -m "update" && git push && \
ssh tencent "cd /www/wwwroot/jianfei && sudo -u www git fetch origin && sudo -u www git checkout $BRANCH_NAME && sudo -u www git pull origin $BRANCH_NAME && sudo chown -R www:www ." && \
echo "✅ 代码已部署，请在宝塔面板重启 jianfei_api 服务"
```

## 验证部署

```bash
# 检查服务状态
ssh tencent "ps aux | grep tsx | grep -v grep"

# 测试API
curl -I https://jfadmin.lanstar.top/api/auth/login
```

## 📝 重要提醒

1. ✅ **每次部署后必须重启Node.js服务**
2. ✅ **构建产物必须一起提交**（dist, dist-admin）
3. ✅ **注意分支！** 确保本地分支和服务器拉取的分支一致
4. ⚠️ **.env文件不会被Git同步**，需要手动维护

## 访问地址

- 用户端: http://www.yourdomain.com
- 管理后台: https://jfadmin.lanstar.top

