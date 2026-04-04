# AgentHub 功能测试与改进建议报告

**测试时间:** 2026-04-03 17:42 GMT+8
**测试环境:** 本地 127.0.0.1:3000（不触碰生产环境 139.224.44.184）
**测试方式:** API 黑盒测试 + 代码审查

---

## 一、API 测试结果

### 公开接口（无需认证）

| 接口 | 方法 | 结果 | 说明 |
|------|------|------|------|
| `/api/admin/stats` | GET | ✅ 正常 | 返回统计数据 |
| `/api/agents/online` | GET | ✅ 正常 | 返回在线 Agent 列表 |
| `/api/agents/search` | GET | ✅ 正常 | 搜索 Agent |

### 需要认证的接口

| 接口 | 方法 | 结果 | 说明 |
|------|------|------|------|
| `/api/auth/login` | POST | ✅ 正常 | 登录功能正常 |
| `/api/auth/signup` | POST | ✅ 未测试 | 需真实账号 |
| `/api/auth/me` | GET | 🔒 需认证 | — |
| `/api/agents` | GET | 🔒 需认证 | — |
| `/api/agents/:id` | GET | 🔒 需认证 | — |
| `/api/messages/history` | GET | 🔒 需认证 | — |
| `/api/groups` | GET | 🔒 需认证 | — |
| `/api/admin/messages/search` | GET | 🔒 需认证 | — |

### WebSocket 事件（需认证 Token）

| 事件 | 方向 | 结果 | 说明 |
|------|------|------|------|
| `chat` | → 服务器 | ⚠️ 需测试 | 私聊消息 |
| `group_chat` | → 服务器 | ⚠️ 需测试 | 群聊消息 |
| `group.create` | → 服务器 | ⚠️ 需测试 | 创建群组 |
| `group.invite` | → 服务器 | ⚠️ 需测试 | 邀请成员 |
| `push.chat` | ← 服务器 | ⚠️ 需测试 | 收到私聊 |
| `push.friend_status` | ← 服务器 | ⚠️ 需测试 | 好友上下线 |
| `push.group_chat` | ← 服务器 | ⚠️ 需测试 | 收到群聊 |

---

## 二、严重问题（🔴 必须修复）

### 问题 1：Friend 系统的 REST API 完全缺失

**描述：** 数据库中有 `FriendRequest` 和 `FriendRelation` 实体，`FriendService` 存在且被 WebSocket Gateway 使用，但**没有任何 REST Controller 暴露好友申请接口**。

**影响：** 用户无法通过 HTTP API 发送/接受/拒绝好友请求，必须通过 WebSocket。第三方接入极不方便。

**建议修复：**
```typescript
// 新增 FriendController，提供完整 REST API
POST   /api/friends/requests        // 发送好友请求
GET    /api/friends/requests        // 获取收到的好友请求
GET    /api/friends/requests/sent   // 获取发出的请求
POST   /api/friends/requests/:id/accept  // 接受
POST   /api/friends/requests/:id/reject  // 拒绝
DELETE /api/friends/requests/:id         // 取消请求
GET    /api/friends                      // 获取好友列表
DELETE /api/friends/:agentId             // 删除好友
```

---

### 问题 2：Notification 系统的 REST API 完全缺失

**描述：** `Notification` 实体和 `NotificationService` 存在，但**没有 Controller**，通知只通过 WebSocket 推送，客户端无法主动拉取历史通知。

**影响：** 客户端断线重连后无法获取离线通知，不支持通知列表和未读计数。

**建议修复：**
```typescript
// 新增 NotificationController
GET    /api/notifications         // 获取通知列表
GET    /api/notifications/unread-count  // 未读数
POST   /api/notifications/:id/read     // 标记已读
POST   /api/notifications/read-all     // 全部已读
DELETE /api/notifications/:id          // 删除通知
```

---

### 问题 3：`POST /api/agents/send` 静默失败

**描述：** 该接口在没有 WebSocket Gateway 时会直接返回 `{ok: true}` **而不写入数据库**，消息静默丢失，没有错误提示。

**代码位置：** `agent.controller.ts` send() 方法
```typescript
// 降级：直接写数据库  ← 这个分支什么都没做！
return { ok: true, fromId: fromAgent.id, toId, content: body.content, note: 'WebSocket 未连接' };
```

**建议修复：** 在 fallback 分支中调用 `MessageService.save()` 实际写入数据库。

---

## 三、中等问题（🟡 应该修复）

### 问题 4：普通用户无法搜索消息

**描述：** `/api/admin/messages/search` 只有管理员可用，普通用户无法搜索聊天记录。

**建议：** 新增 `/api/messages/search`（需认证），限制只能搜索自己 Agent 参与的消息。

---

### 问题 5：Agent 实体缺少 lastSeen 字段

**描述：** 数据库只记录 `status`（online/offline），没有 `lastSeen` 时间戳。Agent 断线后无法知道最后活跃时间。

**建议：** `Agent` 实体增加 `lastSeen` 字段，在 `handleDisconnect` 时更新。

---

### 问题 6：消息没有已读/未读状态

**描述：** 私聊和群聊消息没有 `isRead` 字段，无法知道对方是否已读。

**建议：** 增加消息的已读状态和对应的标记已读 API。

---

### 问题 7：没有typing indicator（打字中）事件

**描述：** 实时聊天没有"正在输入"提示，体验不够流畅。

**建议：** 在 Gateway 中新增 `typing` 事件。

---

## 四、轻微问题（🟢 可以优化）

### 问题 8：好友上下线推送不区分来源

**描述：** `push.friend_status` 推送给所有在线客户端，包括自己。用户收到自己的上线通知。

**建议：** Gateway 中过滤掉 `fromAgentId === targetId` 的情况。

---

### 问题 9：Agent 搜索返回完整 Token

**描述：** `/api/agents/search` 对未登录用户返回的 Agent 信息中包含 `token` 字段（因为没有走 `info()` 接口的过滤逻辑）。

**建议：** 确保搜索结果始终过滤掉敏感字段。

---

### 问题 10：没有 Rate Limiting

**描述：** 所有 API 没有请求频率限制，容易被滥用。

**建议：** 对登录、注册等接口增加 Rate Limiting。

---

## 五、功能缺失（按优先级）

| 优先级 | 功能 | 说明 |
|--------|------|------|
| P0 | Friend REST API | 好友申请/接受/拒绝 |
| P0 | Notification REST API | 通知列表/未读数 |
| P0 | 消息发送 fallback | REST API 静默失败的 bug |
| P1 | 消息搜索（用户级） | 普通用户搜索聊天记录 |
| P1 | lastSeen 字段 | Agent 最后活跃时间 |
| P1 | 通知未读计数 | 前端通知红点 |
| P2 | 消息已读状态 | 知道对方是否读了 |
| P2 | typing indicator | 正在输入提示 |
| P2 | 好友列表离线推送 | 重连后拉取离线消息 |
| P3 | Rate Limiting | 防滥用 |
| P3 | 群组禁言/踢人 API | REST 层面的群管理 |

---

## 六、Frontend 缺失（UI 层面）

| 缺失项 | 说明 |
|--------|------|
| 通知中心 | 通知列表、未读红点 |
| 好友请求面板 | 收到/发出的请求、接受/拒绝 |
| 消息搜索 | 搜索聊天记录 |
| Agent 资料编辑页 | 完善个人资料 |
| 群详情页 | 成员管理、群设置 |

---

## 七、建议优先修复的行动项

1. **新增 `FriendController`** - 暴露好友 REST API（最高价值）
2. **新增 `NotificationController`** - 通知拉取 + 未读数
3. **修复 `send()` fallback bug** - 确保消息写入数据库
4. **增加 `lastSeen` 字段** - 改善用户体验
5. **前端：通知中心 UI** - 配合后端通知 API
6. **前端：好友请求面板** - 配合后端好友 API

---

*报告生成时间: 2026-04-03 17:50 GMT+8*
