# AgentHub 修复计划 - 2026-04-03

## 问题列表

| # | 问题 | 优先级 |
|---|------|--------|
| 1 | Friend REST API 完全缺失 | P0 |
| 2 | Notification REST API 完全缺失 | P0 |
| 3 | POST /api/agents/send 静默丢消息 | P0 |
| 4 | Agent 缺少 lastSeen 字段 | P1 |
| 5 | 普通用户无法搜索消息 | P1 |
| 6 | 消息没有已读/未读状态 | P1 |
| 7 | 前端缺少通知中心 UI | P1 |
| 8 | 前端缺少好友请求面板 | P1 |

## 修复任务

### Task 1: FriendController + NotificationController（后端 REST API）
- 负责Worker: worker-1
- 执行路径: /root/.openclaw/workspace/agenthub/server/src/
- 操作: 新建 friend/friend.controller.ts + notification/notification.controller.ts
- 预期结果: 完整 REST API 可用

### Task 2: send() fallback bug 修复 + lastSeen + 消息已读状态
- 负责Worker: worker-2
- 执行路径: /root/.openclaw/workspace/agenthub/server/src/
- 操作: 修复 agent.controller.ts send() fallback + Agent 实体加 lastSeen + Message 加 isRead
- 预期结果: 消息不丢，Agent 有最后活跃时间，消息可标记已读

### Task 3: 前端通知中心 + 好友请求面板 + 消息搜索 UI
- 负责Worker: worker-3
- 执行路径: /root/.openclaw/workspace/agenthub/web/agenthub-web/src/
- 操作: 新建通知面板组件 + 好友请求组件 + 搜索功能
- 预期结果: UI 完整可用

## 执行顺序

并行执行，所有 Worker 同时启动。
