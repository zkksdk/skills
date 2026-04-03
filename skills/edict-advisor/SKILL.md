---
name: edict-advisor
description: 三省六部 · Edict 多 Agent 协作系统的安装向导与使用顾问。当用户提到"三省六部"、"edict"、"多 Agent 协作"、"AI 分权制衡"时激活。功能：安装部署、看板监控、旨意下发、故障排查。
---

# edict-advisor — 三省六部 · 多 Agent 协作顾问

## 项目概述

**三省六部（Edict）** 是基于 OpenClaw 的多 Agent 协作框架，用 1300 年前的帝国官制实现现代 AI 分权制衡。

**架构流程：**
```
你(皇上) → 太子(分拣) → 中书省(规划) → 门下省(审核) → 尚书省(派发) → 六部(执行)
```

**12 个专职 Agent：**
- 太子(taizi)：消息分拣，闲聊直接回，旨意才建任务
- 中书省(zhongshu)：规划方案
- 门下省(menxia)：审核封驳，质量把关
- 尚书省(shangshu)：调度协调，汇总回奏
- 户部/礼部/兵部/刑部/工部/吏部：专项执行
- 早朝官(zaochao)：每日播报，新闻聚合

---

## 触发词

- "安装三省六部"
- "edict"
- "部署多 Agent"
- "怎么下旨"
- "看板地址"
- "查看任务"
- "中止任务"
- "多 Agent 故障"

---

## 工作流程

### 第一步：检查环境

检查 OpenClaw 是否已安装：
```bash
openclaw --version
python3 --version
```

### 第二步：安装 edict

如果未安装，引导用户：
```bash
# 克隆仓库
git clone https://github.com/cft0808/edict.git
cd edict

# 运行安装脚本
chmod +x install.sh
./install.sh
```

安装脚本自动完成：
- ✅ 创建 12 个 Agent Workspace（含 SOUL.md 人格）
- ✅ 注册 Agent 及权限矩阵到 openclaw.json
- ✅ 符号链接数据目录
- ✅ 同步 API Key 到所有 Agent
- ✅ 重启 Gateway 使配置生效

### 第三步：启动服务

```bash
# 终端 1：数据刷新循环
bash scripts/run_loop.sh

# 终端 2：看板服务器
python3 dashboard/server.py

# 打开浏览器
open http://127.0.0.1:7891
```

### 第四步：下旨（发布任务）

通过任意已配置渠道（飞书/Telegram/Signal）向中书省发送任务：

```
帮我设计一个用户注册系统，要求：
1. RESTful API（FastAPI）
2. PostgreSQL 数据库
3. JWT 鉴权
4. 完整测试用例
```

太子接旨 → 中书省规划 → 门下省审核 → 尚书省派发 → 六部并行执行 → 回奏

### 第五步：监控看板

打开 `http://127.0.0.1:7891` 查看：
- 📋 **旨意看板**：实时任务流转
- 📜 **奏折阁**：已完成任务归档
- 👥 **官员总览**：各 Agent 状态
- ⚙️ **模型配置**：热切换 LLM

---

## 任务状态机

```
Inbox → Zhongshu(规划) → Menxia(审核) → Shangshu(派发) → Doing(执行) → Done
                   ↑ 封驳                      ↑
                   └────── Blocked ←───────────┘
```

| 状态 | 执行者 | 说明 |
|------|--------|------|
| Inbox | 太子 | 收到旨意，待分拣 |
| Zhongshu | 中书省 | 规划中 |
| Menxia | 门下省 | 审核中 |
| Shangshu | 尚书省 | 已派发 |
| Doing | 六部 | 执行中 |
| Done | — | 已完成 |
| Blocked | — | 被阻塞 |
| Cancelled | — | 已取消 |

---

## 看板管理命令

```bash
# 创建任务
python3 scripts/kanban_update.py create JJC-YYYYMMDD-NNN "任务标题" Zhongshu 中书省 中书令

# 更新状态
python3 scripts/kanban_update.py state JJC-YYYYMMDD-NNN Doing "兵部开始执行"

# 查看任务
python3 scripts/kanban_update.py list

# 中止任务
python3 scripts/kanban_update.py cancel JJC-YYYYMMDD-NNN
```

---

## Skill 管理

```bash
# 导入官方 Skills 到指定 Agent
python3 scripts/skill_manager.py import-official-hub \
  --agents zhongshu,menxia,bingbu

# 添加远程 Skill
python3 scripts/skill_manager.py add-remote \
  --agent zhongshu \
  --name code_review \
  --source https://raw.githubusercontent.com/.../SKILL.md

# 查看已安装 Skills
python3 scripts/skill_manager.py list-remote
```

---

## 故障排查

| 症状 | 排查命令 |
|------|----------|
| 任务超时/无回奏 | `curl http://127.0.0.1:7891/api/agents-status` |
| Agent 不在线 | 检查 Gateway：`openclaw status` |
| Skill 下载失败 | `curl -I <skill-url>` 测试网络 |
| 看板空白 | 重启 `python3 dashboard/server.py` |
| 任务无法创建 | 检查 `data/` 目录写入权限 |

```bash
# 强制重试卡住的任务
curl -X POST http://127.0.0.1:7891/api/scheduler-scan \
  -H 'Content-Type: application/json' \
  -d '{"thresholdSec":60}'
```

---

## Agent 权限矩阵

| 从→ | 太子 | 中书 | 门下 | 尚书 | 六部 |
|------|:---:|:---:|:---:|:---:|:---:|
| 太子→ | — | ✅ | | | |
| 中书省→ | ✅ | — | ✅ | ✅ | |
| 门下省→ | | ✅ | — | ✅ | |
| 尚书省→ | | ✅ | ✅ | — | ✅ |
| 六部→ | | | | ✅ | |

想发消息给对方，必须在矩阵中有路径，否则被拒绝。

---

## 项目信息

- 仓库：https://github.com/cft0808/edict
- Demo：`docker run -p 7891:7891 cft0808/sansheng-demo`
- 看板：http://127.0.0.1:7891
- Agent 数量：12 个（+ 1 个兼容）
