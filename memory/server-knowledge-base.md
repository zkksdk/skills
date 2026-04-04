# 服务器知识库

> 建立时间：2026-04-04
> 最后更新：2026-04-04

---

## 服务器基本信息

| 项目 | 值 |
|------|-----|
| 主机名 | VM-0-15-ubuntu |
| 系统 | Ubuntu 24.04.4 LTS (Noble Numbat) |
| 内核 | Linux 6.8.0-101-generic x86_64 |
| 公网IP | 49.233.249.103 |
| 架构 | x86_64 |
| 磁盘总量/已用 | 50G / 24G (50%) |

---

## 网络端口

| 端口 | 进程 | 说明 |
|------|------|------|
| 22 | sshd | SSH |
| 53 | systemd-resolve | DNS |
| 3000 | node dist/main | AgentHub 后端 API |
| 8080 | node /tmp/serve-with-ws.js | AgentHub Web 前端代理 |
| 10599 | openclaw-gateway (pid 856958) | OpenClaw 网关（主要） |
| 19001 | openclaw-gateway (pid 863850) | OpenClaw 辅助端口 |
| 19002 | openclaw-gateway (pid 863898) | OpenClaw 辅助端口 |

---

## OpenClaw 配置

**配置文件**：`/root/.openclaw/openclaw.json`

**版本**：2026.3.28
**安装路径**：`/root/.local/share/pnpm/openclaw`

**网关配置**：
- 端口：10599
- 绑定模式：lan (0.0.0.0)
- 认证方式：token
- Token：`660f262b62abf257875afbf6006e5130b96c2c2fdfceecb5`
- Control UI 路径：`/1uqm1o`

**模型配置**：
- 主模型：minimax/MiniMax-M2.7
- API Key：已配置（Minimax）

**已安装插件**：
- `memory-tdai` (0.1.2) ✅ 启用
- `feishu` ✅ 启用
- `openclaw-qqbot` ❌ 禁用
- `ddingtalk` ❌ 禁用
- `wecom` ❌ 禁用
- `adp-openclaw` ❌ 禁用
- `openclaw-plugin-yuanbao` ❌ 禁用
- `openclaw-weixin` ❌ 禁用
- `lightclawbot` ❌ 禁用

---

## AgentHub 配置

**项目路径**：
- `/root/agenthub/` — AgentHub 主目录
- `/root/.openclaw/workspace/agenthub/` — 本地工作区副本

**AgentHub 前端源码**：
- `/root/agenthub/web/agenthub-web/` (npm 项目)
- 源码：`src/pages/owner/Dashboard.tsx` — 接入向导按钮在此

**构建产物**：
- `/root/agenthub/web/agenthub-web/dist/` — 实际服务目录

**启动文件**：`/tmp/serve-with-ws.js`
- 监听：0.0.0.0:8080
- 静态目录：`/root/agenthub/web/agenthub-web/dist/`
- API 代理到：127.0.0.1:3000
- 根路径 `/` → `setup.html`

**AgentHub 后端 API**：`/root/agenthub/server/`
- 端口：3000
- 状态：运行中

**AgentHub 在线 Agent**：
| Agent ID | 名称 | 状态 |
|----------|------|------|
| 74d00805-3ea2-4a64-b260-03b47bdd8754 | Clone-01 | online |

**AgentHub 统计数据**：
- 用户总数：9
- Agent 总数：6
- 在线 Agent：1
- 群聊数：1
- 消息总量：0

---

## 已知问题与修复记录

### 问题1：接入向导按钮跳转到外部服务器

**现象**：点击"查看接入向导"按钮后，浏览器跳转到 `https://790h3zymqjwf.space.minimaxi.com`

**根因**：
- 源码 `Dashboard.tsx` 中硬编码了 `window.open('https://790h3zymqjwf.space.minimaxi.com', '_blank')`
- 编译后的 JS bundle 路径：`/root/agenthub/web/agenthub-web/dist/assets/index-B2SkEyAM.js`
- 该 URL 以字符串形式存在于 bundle 中

**受影响的源码文件**：
- `/root/agenthub/web/agenthub-web/src/pages/owner/Dashboard.tsx` (第159行附近)

**正确的行为应该是**：打开本地的 `setup.html`（即 `http://49.233.249.103:8080/setup.html`）

**修复方案**：
1. 修改 `Dashboard.tsx` 源码，将硬编码 URL 改为 `/setup.html`
2. 重新编译前端：`cd /root/agenthub/web/agenthub-web && npm run build`
3. 重启 `serve-with-ws.js` 或重新部署 dist 目录

**修复状态**：⚠️ 待修复（截至 2026-04-04）

---

### 问题2：setup.html 同步路径混乱

**现象**：之前将 setup.html 同步到了错误的路径

**正确路径**：`/root/agenthub/web/agenthub-web/dist/setup.html`
**错误路径**（已同步但未使用）：`/root/.openclaw/workspace/agenthub/web/agenthub-web/dist/setup.html`

**说明**：`/tmp/serve-with-ws.js` 的 `DIST_DIR` 配置为 `/root/agenthub/web/agenthub-web/dist`，所以只有该路径下的文件会被服务

---

## 关键文件路径速查

```
/root/.openclaw/openclaw.json          # OpenClaw 主配置
/tmp/serve-with-ws.js                  # AgentHub Web 启动脚本
/root/agenthub/                        # AgentHub 主目录
/root/agenthub/web/agenthub-web/dist/  # AgentHub 前端构建产物（8080服务）
/root/agenthub/server/                 # AgentHub 后端
/root/.openclaw/workspace/agenthub/    # workspace 下的 AgentHub（副本）
```

---

## 快速命令

```bash
# 查看 OpenClaw 网关状态
openclaw gateway status

# 重启 OpenClaw 网关
openclaw gateway restart

# 查看端口占用
ss -tlnp | grep -v "127.0.0.1"

# 查看 AgentHub API 在线状态
curl http://127.0.0.1:3000/api/agents/online

# 查看 AgentHub 统计
curl http://127.0.0.1:3000/api/admin/stats

# 查看 setup.html 是否可访问
curl http://49.233.249.103:8080/setup.html | head -5
```
