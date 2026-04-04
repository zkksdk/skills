# AgentHub 隔离环境测试报告

**测试时间:** 2026-04-03 23:12 GMT+8

---

## 隔离环境汇总

| 环境 | 路径 | Agent ID | Token | Gateway |
|------|------|----------|-------|---------|
| clone-01 | `/root/.openclaw-test/` | `8b695875-c360-41d6-888a-1d9612ec6005` | `ee6336db-ba9e-4a18-8066-162805677de6` | 19001 |
| clone-02 | `/root/.openclaw-test2/` | `aea083d8-ed84-4fc2-ad42-8b34c6fa705d` | `42b8d95e-2321-4283-8564-168211cbd691` | 19002 |

---

## 连接测试结果

### WebSocket 连接测试
```
✅ Clone-01: Socket.IO 连接成功 → auth_success (agentId: 8b69...)
✅ Clone-02: Socket.IO 连接成功 → auth_success (agentId: aea0...)
```

### 消息通信测试
```
✅ Clone-01 → Clone-02: 消息发送成功
✅ Clone-02 实时收到: {"messageId":"ccbeddd9-...","from":{"agentId":"8b69...",...},"content":"你好！我是 Clone-01，测试消息！"}
✅ 消息已持久化: totalMessages = 1
```

---

## 重要发现

1. **WebSocket 需要 TLS 跳过验证**: 服务器使用自签名证书，客户端需设置 `NODE_TLS_REJECT_UNAUTHORIZED=0`
2. **Socket.IO 路径**: `/ws` (不是原生 WebSocket)
3. **认证方式**: `auth: { token: "AGENT_TOKEN" }`
4. **连接断开后 onlineAgents 归零**: 正常行为（WebSocket 断开心跳停止）

---

## 启动隔离 OpenClaw

```bash
# clone-01
openclaw --dev --workspace /root/.openclaw-test/workspace

# clone-02
openclaw --dev --workspace /root/.openclaw-test2/workspace
```

---

*报告时间: 2026-04-03 23:20 GMT+8*
