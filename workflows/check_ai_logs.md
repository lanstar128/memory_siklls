---
description: 在服务器上查询 AI 响应日志（用于问题排查）
---

# 查询 AI 响应日志

用于排查 AI 返回数据的问题，例如时间推断错误、分析结果异常等。

## 查询最近的 AI 响应日志

// turbo
```bash
ssh tencent "mongosh slothfit --eval 'db.airesponselogs.find().sort({createdAt:-1}).limit(5).forEach(doc => { print(\"\\n===== \" + doc.createdAt + \" =====\"); print(\"用户消息: \" + doc.userMessage); print(\"AI short_title: \" + doc.aiResponse?.short_title); print(\"AI analysis: \" + JSON.stringify(doc.aiResponse?.analysis, null, 2)); print(\"AI multipleAnalysis: \" + JSON.stringify(doc.aiResponse?.multipleAnalysis, null, 2)); print(\"处理时间: \" + doc.processingTimeMs + \"ms\"); })'"
```

## 按用户 ID 查询

```bash
# 先获取用户 ID（通过用户名搜索）
ssh tencent "mongosh slothfit --eval 'db.users.find({name: /用户名/}).forEach(u => print(u._id + \" - \" + u.name))'"

# 然后按用户 ID 查询日志
ssh tencent "mongosh slothfit --eval 'db.airesponselogs.find({userId: ObjectId(\"用户ID\")}).sort({createdAt:-1}).limit(10).forEach(doc => { print(\"\\n===== \" + doc.createdAt + \" =====\"); print(\"用户消息: \" + doc.userMessage); print(\"AI short_title: \" + doc.aiResponse?.short_title); print(\"multipleAnalysis: \" + JSON.stringify(doc.aiResponse?.multipleAnalysis)); })'"
```

## 查看日志统计

// turbo
```bash
ssh tencent "mongosh slothfit --eval 'print(\"AI日志总数: \" + db.airesponselogs.countDocuments()); print(\"今日日志: \" + db.airesponselogs.countDocuments({createdAt: {\$gte: new Date(new Date().setHours(0,0,0,0))}}))'"
```

## 查看特定时间段的日志

```bash
# 查看某个小时内的日志（例如 11:00-12:00）
ssh tencent "mongosh slothfit --eval 'db.airesponselogs.find({createdAt: {\$gte: new Date(\"2025-12-16T03:00:00Z\"), \$lt: new Date(\"2025-12-16T04:00:00Z\")}}).forEach(doc => { print(doc.createdAt + \": \" + doc.userMessage?.substring(0,50)); })'"
```

## 日志字段说明

| 字段 | 说明 |
|------|------|
| userMessage | 用户发送的消息（截断500字） |
| aiResponse.reply | AI 回复内容 |
| aiResponse.short_title | AI 生成的简短标题 |
| aiResponse.analysis | 单条分析结果（旧格式） |
| aiResponse.multipleAnalysis | 多条分析结果（新格式，包含 actualTimestamp、timeContext 等） |
| inputTokens / outputTokens | Token 消耗 |
| processingTimeMs | AI 处理时间（毫秒） |
