# ClawHub 学习报告 — 技能与插件制作指南
生成时间：2026-04-03
数据来源：clawhub.ai（100+ 技能页面采样 + clawhub CLI 深度检查）

---

## 一、技能（Skills）分析

### 1.1 技能整体数据

- **ClawHub 技能总量**：44,705 个（持续增长）
- **热门技能类型分布**（按下载量排序）：
  - 🔴 开发类（coding, debugging, testing, API）
  - 🔴 效率类（productivity, automation, workflow）
  - 🟡 内容类（writing, summarization, research）
  - 🟡 安全类（security audit, permission）
  - 🟢 平台集成类（Slack, DingTalk, WeChat, Telegram）
  - 🟢 知识管理类（memory, context, RAG）
  - 🟢 工具类（file, image, video, audio processing）

### 1.2 SKILL.md 标准结构

**Frontmatter（YAML 头）：**
```yaml
---
name: skill-name           # 唯一标识，英文小写+连字符
description: "描述文本，触发词+功能说明"  # 最关键字段
---
```

**Description 字段写法（最重要）：**
- 格式：`触发词1, 触发词2, ... — 完整功能描述`
- 触发词：用户可能说的关键词，用逗号分隔
- 示例：
  ```
  description: "coding, code review, debugging — Full-stack development
    expert. Write code, review PRs, debug issues, explain architecture.
    Triggers on: write code, fix bug, code review, debug"
  ```
- 中文技能示例：
  ```
  description: "docker helper, dockerfile, 容器 — Dockerfile生成、
    docker-compose编排、命令速查、调试排错"
  ```

**Markdown Body 结构（建议顺序）：**
1. `# 标题` — 技能名称 + 一句话描述
2. `## Overview` — 详细功能说明
3. `## Workflow` — 使用流程/步骤
4. `## Inputs` — 需要收集的用户输入
5. `## Examples` — 使用示例（JSON/代码）
6. `## Outputs` — 输出格式说明
7. `## 通用行为准则` — AI 行为规范（如沟通方式、输出质量）
8. `## 触发条件` — 补充说明

### 1.3 技能分类与典型模式

**A. 开发类技能（最热门）**

典型触发词：`coding, code review, debugging, write code, fix bug, frontend, backend, API`

SKILL.md 特点：
- 强调"输出可直接运行的代码"
- 包含完整的依赖安装命令
- 有代码质量评分和审查维度
- 覆盖多个技术栈（Vue/React/SpringBoot/Node.js）

示例结构：
```markdown
# AI Coder — 全栈开发专家

## Overview
精通全栈开发、代码审查、UI/UX设计...

## Workflow
1. 需求澄清 → 2. 方案设计 → 3. 代码实现 → 4. 代码审查

## 代码实现规范
- 前端：Vue3 组合式 API，TypeScript 类型定义
- 后端：RESTful 接口，异常处理，SQL 注入防护
```

**B. 平台集成类技能**

典型触发词：`slack, telegram, dingtalk, wechat, discord — messaging, channel`

SKILL.md 特点：
- 描述触发条件而非完整流程
- 说明"这个技能什么时候被调用"
- 重点说明 actions/工具调用格式
- 通常提供 JSON 格式的 action 示例

示例：
```yaml
description: "Use when you need to control Slack from Clawdbot via
  the slack tool, including reacting to messages or pinning/unpinning
  items in Slack channels or DMs. Triggers on: slack, react to message,
  send slack message, pin message"
```

```markdown
# Slack Actions

## Overview
Use `slack` to react, manage pins, send/edit/delete messages...

## Inputs
- channelId and messageId (Slack message timestamp)
- emoji (Unicode or :name:)
- content and to target

## Actions
| Action | Default | Notes |
|--------|---------|-------|
| reactions | enabled | React + list reactions |
| messages | enabled | Read/send/edit/delete |

## Examples
{"action": "react", "channelId": "C123", "messageId": "...", "emoji": "✅"}
```

**C. Bot 协作类技能**

典型触发词：`bot communication, cross-bot, multi-agent, bot to bot`

SKILL.md 特点：
- 有 Social Graph / Relationships Table
- 有路由决策逻辑（直连/中转）
- 有多 Bot 协作流程图

```markdown
# cross-bot-communication

## Social Relationships
| Bot | Owner | Platform | Direct Connect | Group |
|-----|-------|----------|---------------|-------|
| @Alice | User1 | Telegram | ✅ | ✅ |
| @Bob | User2 | Discord | ✅ | ❌ |

## Routing Strategy
1. 同群 → 直连
2. 跨群/跨平台 → Channel 中转
3. 管理员 Bot → @mention 直接调用
```

**D. 安全/审计类技能**

典型触发词：`security audit, permission check, vulnerability scan`

SKILL.md 特点：
- 有检查清单（checklist）格式
- 分级标注风险（🔴🔴 高危 / 🟡 中危 / 🟢 低危）
- 有修复建议和加固方案

### 1.4 技能命名规律

- **英文技能**：`[类型]-[功能]` 或 `[平台]-[功能]`
  - `self-improving-agent`、`coding-lead`、`api-tester`
  - `vibe-coding`、`cursor-context`、`context7`
- **中文技能**：`[中文名]-[英文标识]`
  - `docker-helper`（docker+helper）
  - `web-content-fetcher`（网页内容获取）
- **平台类**：`[平台]-[功能]`
  - `dingtalk`、`slack`、`wechat`

### 1.5 技能版本管理

- 大多数技能使用语义化版本：`1.0.0`、`2.0.0`
- ClawHub 支持多版本标签：`chinese=1.0.0, latest=2.0.0, productivity=1.0.0`
- 热门技能通常有中文版和英文版两个标签

---

## 二、插件（Plugins）分析

### 2.1 插件架构概述

ClawHub 插件是让 OpenClaw 连接外部服务的通道（如 Telegram、DingTalk、WeChat）。每个插件是一个完整的 Node.js 包。

**插件必须包含的文件：**

| 文件 | 必需 | 说明 |
|------|------|------|
| `openclaw.plugin.json` | ✅ | 插件清单，OpenClaw 加载入口 |
| `index.js` | ✅ | 插件主入口，连接外部服务 |
| `SKILL.md` | ✅ | 技能说明，供 AI 理解如何使用 |
| 其他支持文件 | ❌ | 如 setup.sh、README.md |

### 2.2 openclaw.plugin.json 标准格式

```json
{
  "id": "channel-agenthub",       // 唯一标识（必填）
  "channels": ["agenthub"],       // channel 名称数组（必填）
  "configSchema": {                // 配置 schema（必填，否则报错）
    "type": "object",
    "additionalProperties": true   // 允许任意额外字段
  }
}
```

**字段说明：**
- `id`：插件唯一 ID，与目录名一致
- `channels`：插件提供的 channel 名称数组
- `configSchema`：配置验证 schema（至少要有 `type: object`）

### 2.3 index.js 标准结构

```javascript
// OpenClaw Channel Plugin — 示例（参考 dingtalk 格式）

class MyChannelPlugin {
  // 构造函数：接收配置，初始化连接
  constructor(config) {
    this.serverUrl = config.serverUrl;
    this.agentId = config.agentId;
    this.agentToken = config.agentToken;
    this.ws = null;
    this.reconnectDelay = config.reconnectDelay || 3000;
  }

  // OpenClaw 调用：加载插件
  async load(container) {
    this.container = container;
    await this.connect();
  }

  // OpenClaw 调用：卸载插件
  async unload() {
    if (this.ws) this.ws.disconnect();
  }

  // 建立 Socket.IO 连接
  async connect() {
    const { io } = require('socket.io-client');
    this.ws = io(this.serverUrl, {
      path: '/ws',                          // WebSocket 路径
      auth: { token: this.agentToken },     // 认证 token
      transports: ['websocket', 'polling'],
      reconnection: true,
      rejectUnauthorized: false,            // 自签证书必加
    });

    this.ws.on('connect', () => {
      console.log('[channel-agenthub] connected:', this.ws.id);
      this.updateStatus('online');
    });

    // 监听来自服务器的消息
    this.ws.on('push.chat', (data) => this.handleMessage(data));
    this.ws.on('push.friend_status', (data) => this.handleStatus(data));

    this.ws.on('disconnect', () => this.updateStatus('offline'));
  }

  // 处理收到的消息
  handleMessage(data) {
    // data.from, data.content, data.to, data.messageId
    this.container.sendToMaster({
      type: 'message',
      from: data.from.agentId,
      content: data.content,
      chatId: data.from.agentId,  // 私聊用 from 作为 chatId
      subtype: 'text',
    });
  }

  // 处理状态变化
  handleStatus(data) {
    this.container.sendToMaster({
      type: 'status',
      agentId: data.agentId,
      status: data.status,
    });
  }

  // 实现 Channel 接口：发送消息
  async sendMessage(to, content, type = 'text') {
    this.ws.emit('chat', { to, content }, (res) => {
      if (res?.ok) console.log('[channel-agenthub] sent:', res.messageId);
    });
  }

  updateStatus(status) {
    this.container.setStatus(status);
  }
}

module.exports = MyChannelPlugin;
```

### 2.4 SKILL.md（插件配套技能）

插件的 SKILL.md 与普通技能不同，更偏向"工具说明"而非"完整工作流"：

```yaml
---
name: channel-agenthub
description: "channel plugin for AgentHub. Triggers when: config agenthub,
  setup agenthub channel, connect to agenthub. This skill explains how
  to configure the AgentHub channel plugin."
---

# AgentHub Channel Plugin

## Overview
This plugin connects OpenClaw to an AgentHub server via Socket.IO...

## Configuration
- serverUrl: AgentHub 服务器地址（不需要写端口，走 nginx）
- agentId: 从 AgentHub 后台复制的 Agent ID
- agentToken: 从 AgentHub 后台复制的 Token

## Setup
1. Download and install the plugin
2. Configure openclaw.json with your credentials
3. Reload OpenClaw gateway

## Usage
Once configured, the plugin maintains a persistent Socket.IO
connection to the AgentHub server and relays messages...
```

### 2.5 插件安装流程（完整）

```bash
# 1. 下载插件目录
mkdir -p ~/.openclaw/extensions/channel-agenthub/src/
curl -sL "https://YOUR-SERVER/static/channel/index.js" -o \
  ~/.openclaw/extensions/channel-agenthub/src/index.js

# 2. 创建 openclaw.plugin.json
cat > ~/.openclaw/extensions/channel-agenthub/src/openclaw.plugin.json << 'EOF'
{
  "id": "channel-agenthub",
  "channels": ["agenthub"],
  "configSchema": { "type": "object", "additionalProperties": true }
}
EOF

# 3. 配置 openclaw.json（通过 gateway config.patch）
# 4. 触发热重载：kill -USR1 $(pgrep -f "openclaw gateway")
```

---

## 三、对比：技能 vs 插件

| 维度 | 技能（Skill） | 插件（Plugin） |
|------|--------------|---------------|
| **本质** | AI 工作流规范 | 外部服务连接器 |
| **加载方式** | SKILL.md 被 AI 读取理解 | openclaw.plugin.json 被 Gateway 加载 |
| **触发方式** | 用户对话触发词 | 系统事件（消息/状态变化） |
| **是否可删除** | 可随时删除/修改 | 删除后 Gateway 断开连接 |
| **配置位置** | AI 通过 prompt 理解 | openclaw.json 的 channels 字段 |
| **文件数量** | 至少 SKILL.md | 至少 openclaw.plugin.json + index.js |
| **中文名** | 有（中文描述） | 有（DingTalk/WeChat） |

**关系**：插件提供连接能力，技能提供使用规范。插件是通道，技能是说明书。

---

## 四、对 AgentHub 的改进建议

### 4.1 技能（SKILL.md）改进

**当前问题**：AgentHub 的 channel 插件 SKILL.md 描述过于简单，缺少：
- 触发词覆盖（只写了 setup）
- 没有消息格式说明（消息结构、字段）
- 没有错误处理说明

**建议格式**：
```yaml
---
name: channel-agenthub
description: "agenthub, agent hub, bot chat, multi-agent — Connect OpenClaw
  to an AgentHub server. Use when: configuring agenthub channel, sending
  messages between bots, creating group chats via agenthub. Handles: chat
  messages (text, markdown), status updates (online/offline), group invites."
---

# AgentHub Channel Plugin

## Overview
Bidirectional bridge between OpenClaw and AgentHub server...

## Connection
- Protocol: Socket.IO over HTTPS
- Path: /ws
- Auth: Bearer token (agentToken)

## Message Format
Inbound (from AgentHub → OpenClaw):
{"type": "message", "from": "agentId", "content": "..."}

Outbound (from OpenClaw → AgentHub):
{"type": "chat", "to": "agentId", "content": "..."}

## Status Mapping
- OpenClaw online + socket connected → AgentHub "online"
- OpenClaw offline / socket disconnect → AgentHub "offline"
```

### 4.2 插件架构建议

参考 `cross-bot-communication` 的思路：

1. **Bot 发现机制**：让 AgentHub 支持查询所有在线 Bot
2. **Bot → Bot 私信**：Socket.IO 的 `chat` 事件已支持
3. **社交关系表**：记录 owner 有哪些 Bot、Bot 之间关系
4. **路由逻辑**：同平台直连、跨平台走中转

---

## 五、数据附录

### A. 技能分类采样（按下载量前 20）

| 技能名 | 类型 | 触发词摘要 |
|--------|------|-----------|
| self-improving-agent | 反思优化 | self-improving, reflection |
| agentic-security-audit | 安全审计 | security audit, vulnerability |
| web-content-fetcher | 网页内容 | extract content, summarize |
| coding-lead | 开发管理 | coding lead, code review |
| api-tester | API 测试 | API testing, endpoint |
| cursor-context | IDE 上下文 | Cursor, context |
| context7 | 知识库 | knowledge base, RAG |
| memory-exporter | 记忆导出 | memory export |
| slack | 平台集成 | slack, react, pin |
| docker-helper | 容器 | docker, dockerfile |
| vibe-coding | 语音编码 | voice coding, mobile |

### B. 插件文件清单

```
channel-agenthub/
├── openclaw.plugin.json   ← 插件清单（必需）
├── index.js               ← 插件主入口（必需）
├── SKILL.md               ← 技能说明（必需）
├── setup.sh               ← 安装脚本（可选）
└── README.md              ← 使用文档（可选）
```
