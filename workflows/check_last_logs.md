---
description: MongoDB Atlas 数据库查看与调试指南
---

### 1. 概述
在数据库迁移到 **MongoDB Atlas** 云端后，我们拥有多种比直接在服务器运行脚本更高效的数据查看方式。本指引旨在帮助您快速、安全地访问数据。

---

### 2. 方式 A：Atlas Web 控制台（最直观）
直接在浏览器中查看、统计和修改数据，无需任何本地配置。

1. **登录地址**: [MongoDB Atlas 控制台](https://cloud.mongodb.com/)
2. **定位集合**:
   - 进入项目集群（Cluster）。
   - 点击 **Browse Collections** 标签页。
   - 在左侧选择数据库 `slothfit`（参考 `.env` 中的名称）及对应的集合（如 `activitylogs`）。
3. **功能**: 支持强大的过滤语法（Filter），可实时查看数据结构。

---

### 3. 方式 B：MongoDB Compass / 开发者工具（最专业）
使用本地图形化管理工具进行深度调试。

1. **获取链接**: 从项目的 `.env` 文件中复制 `MONGO_URI`。
   - 格式通常为：`mongodb+srv://lanhuguxing_db_user:<password>@jianfei.jubgozx.mongodb.net/...`
2. **连接工具**:
   - 打开 **MongoDB Compass**。
   - 点击 **New Connection**。
   - 直接粘贴 `MONGO_URI`，点击 **Connect**。
3. **优势**: 支持分片查询、地理位置可视化及索引管理。

---

### 4. 方式 C：服务器快速查询（紧急/自动化）
如果您已经在服务器终端，可以使用以下“一键式”命令查看最新日志。

```bash
# SSH 到腾讯云服务器
ssh tencent

# 在项目根目录下运行
cd /www/wwwroot/jianfei
sudo -u www npx tsx -e '
import mongoose from "mongoose";
import dotenv from "dotenv";
dotenv.config();
const run = async () => {
  await mongoose.connect(process.env.MONGO_URI);
  const Log = mongoose.model("ActivityLog", new mongoose.Schema({}), "activitylogs");
  const logs = await Log.find().sort({_id: -1}).limit(5);
  console.log(JSON.stringify(logs, null, 2));
  process.exit(0);
};
run();'
```

---

### 5. 注意事项
- **IP 白名单**: 如果本地工具（方式 B）连接失败，请检查 Atlas 控制台中的 **Network Access**，确保您的当前 IP 已加入白名单。
- **配置同步**: 所有的连接均基于 `.env` 中的密钥，请勿对该文件进行未授权的变动。

---

### 6. 常用调试命令

#### 按日期范围查询日志
```bash
ssh tencent 'cd /www/wwwroot/jianfei && sudo -u www npx tsx -e "
import mongoose from \"mongoose\";
import dotenv from \"dotenv\";
dotenv.config();
const run = async () => {
  await mongoose.connect(process.env.MONGO_URI);
  const Log = mongoose.model(\"ActivityLog\", new mongoose.Schema({}, {strict: false}), \"activitylogs\");
  const logs = await Log.find({ date: { \\\$in: [\"2025-12-23\", \"2025-12-24\"] } }).sort({date: 1, createdAt: 1}).lean();
  console.log(JSON.stringify(logs, null, 2));
  process.exit(0);
};
run();
"'
```

#### 查询体重日志
```bash
ssh tencent 'cd /www/wwwroot/jianfei && sudo -u www npx tsx -e "
import mongoose from \"mongoose\";
import dotenv from \"dotenv\";
dotenv.config();
const run = async () => {
  await mongoose.connect(process.env.MONGO_URI);
  const Log = mongoose.model(\"ActivityLog\", new mongoose.Schema({}, {strict: false}), \"activitylogs\");
  const logs = await Log.find({ type: \"weight\" }).sort({createdAt: -1}).limit(10).lean();
  console.log(JSON.stringify(logs, null, 2));
  process.exit(0);
};
run();
"'
```

#### 清理重复体重记录（危险操作）
```bash
# 删除格式为 "体重记录: XXkg" 的重复日志，保留 "体重: XXkg" 格式
ssh tencent 'cd /www/wwwroot/jianfei && sudo -u www npx tsx -e "
import mongoose from \"mongoose\";
import dotenv from \"dotenv\";
dotenv.config();
const run = async () => {
  await mongoose.connect(process.env.MONGO_URI);
  const Log = mongoose.model(\"ActivityLog\", new mongoose.Schema({}, {strict: false}), \"activitylogs\");
  const result = await Log.deleteMany({ type: \"weight\", \"content.name\": { \\\$regex: /^体重记录:/ } });
  console.log(\"删除数量:\", result.deletedCount);
  process.exit(0);
};
run();
"'
```
