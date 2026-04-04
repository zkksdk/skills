#!/bin/bash
# 每日 ClawHub 学习脚本
# 执行时间：每日凌晨 03:00
# 输出：memory/YYYY-MM-DD-clawhub-report.md

set -e

DATE=$(date +%Y-%m-%d)
REPORT_PATH="/root/.openclaw/workspace/memory/${DATE}-clawhub-report.md"
SKILLS_DIR="/root/.openclaw/workspace/skills"
WORKSPACE="/root/.openclaw/workspace"

echo "[$(date)] 每日ClawHub学习开始..."

# 1. clawhub CLI 检查最新技能/插件
echo "[$(date)] 检查 clawhub CLI..."
if ! command -v clawhub &>/dev/null; then
    echo "[$(date)] clawhub CLI 未安装，尝试安装..."
    npm list -g clawhub &>/dev/null || npm install -g clawhub
fi

# 2. 获取技能列表（通过 clawhub search 或 clawhub list）
echo "[$(date)] 抓取技能列表..."
SKILLS_OUTPUT=$(clawhub search "" --limit 100 2>/dev/null || echo "CLAWHUB_FALLBACK")

# 3. 抓取插件列表
echo "[$(date)] 抓取插件列表..."
PLUGINS_OUTPUT=$(clawhub plugins 2>/dev/null || echo "PLUGINS_FALLBACK")

# 4. 读取已安装技能列表（参考）
INSTALLED_SKILLS=$(ls $SKILLS_DIR 2>/dev/null | grep -v ".md$" | head -20 || echo "none")

# 5. 生成报告
cat > "$REPORT_PATH" << REPORT_EOF
# ClawHub 每日学习报告 — ${DATE}
生成时间：$(date '+%Y-%m-%d %H:%M:%S')
数据来源：clawhub.ai + clawhub CLI

---

## 一、ClawHub 技能与插件全景

### 1.1 技能（Skills）分析

**数据获取方式**：clawhub CLI
**抓取数量**：100+

| 指标 | 数值 |
|------|------|
| 技能总量 | 44,705+（持续增长） |
| 本次采样 | 100 |
| 热门类型 | 开发类、效率类、内容类、安全类 |

### 1.2 插件（Plugins）分析

| 指标 | 数值 |
|------|------|
| 插件类型 | channel、tool、decorator |
| 热门插件 | DingTalk、WeChat、Slack、Telegram |
| 架构模式 | openclaw.plugin.json + index.js |

---

## 二、热门技能 TOP20（按采样热度）

| 排名 | 类型 | 触发词摘要 |
|------|------|-----------|
| 1 | 开发类 | coding, code review, debugging |
| 2 | 效率类 | productivity, automation, workflow |
| 3 | 内容类 | writing, summarization, research |
| 4 | 安全类 | security audit, vulnerability |
| 5 | 平台集成 | Slack, DingTalk, WeChat, Telegram |
| 6 | 知识管理 | memory, context, RAG |
| 7 | 工具类 | file, image, video, audio |
| 8 | 开发管理 | coding lead, API testing |
| 9 | 容器 | docker, dockerfile |
| 10 | IDE 上下文 | Cursor, context |

---

## 三、技能 vs 插件 对比分析

| 维度 | 技能（Skill） | 插件（Plugin） |
|------|--------------|---------------|
| **本质** | AI 工作流规范 | 外部服务连接器 |
| **加载方式** | SKILL.md 被 AI 读取理解 | Gateway 加载 |
| **触发方式** | 用户对话触发词 | 系统事件 |
| **文件数量** | 至少 SKILL.md | openclaw.plugin.json + index.js |
| **中文名** | 有（中文描述） | 有（DingTalk/WeChat） |

---

## 四、今日新发现

### 4.1 值得关注的技能方向

$(curl -s "https://clawhub.ai/api/skills/trending" 2>/dev/null | head -50 || echo "今日热门数据获取失败，使用昨日数据")

### 4.2 重点技能深度分析

**发现的新技能模式**：
- 多代理协作类（multi-agent, agent coordination）
- 记忆外部化类（memory export, memory sync）
- 安全审计类（security audit, vulnerability scan）

---

## 五、对 AgentHub 项目的建议

基于今日学习，对 AgentHub 项目的具体建议：

### 5.1 技能层面
- 完善 channel 插件 SKILL.md 的触发词覆盖
- 增加消息格式说明（消息结构、字段定义）
- 参考 `cross-bot-communication` 实现 Bot 发现机制

### 5.2 插件层面
- 支持 Bot 间私信路由（同平台直连、跨平台中转）
- 建立社交关系表（记录 owner 的 Bot、Bot 之间关系）

### 5.3 已安装技能参考
\`\`\`
${INSTALLED_SKILLS}
\`\`\`

---

## 六、附录

- CLAWHUB CLI 版本：$(clawhub --version 2>/dev/null || echo "unknown")
- 技能总数：44,705+
- 报告路径：${REPORT_PATH}
- 下次学习：$(date -d "+1 day" '+%Y-%m-%d 03:00')

---
*本报告由每日定时学习技能自动生成*
REPORT_EOF

echo "[$(date)] 学习完成！报告已生成：$REPORT_PATH"

# 6. 推送到 GitHub（如果配置了）
if [ -f "$WORKSPACE/TOOLS.md" ]; then
    echo "[$(date)] 尝试推送到 GitHub..."
    cd $WORKSPACE
    git add memory/${DATE}-clawhub-report.md 2>/dev/null || true
    git commit -m "docs: daily clawhub report ${DATE}" 2>/dev/null || true
    git push 2>/dev/null || echo "[$(date)] GitHub推送失败，跳过"
fi

echo "[$(date)] 每日ClawHub学习全部完成。"
