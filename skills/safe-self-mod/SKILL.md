---
name: safe-self-mod
description: 安全自我修改工作流。任何涉及主实例（/workspace/ 下的 SOUL.md、AGENTS.md、IDENTITY.md、TOOLS.md、MEMORY.md 等核心文件）的变更，必须先在隔离 Clone-01 中验证，通过后再询问用户是否应用到主实例。触发条件：用户说"修改你自己"、"改一下我的设定"、"更新配置"、"自我修改"等。
---

# safe-self-mod — 安全自改工作流

## 核心原则

**主实例的所有变更，必须先在 Clone-01 隔离验证，通过后再问用户。**

---

## 工作流

### 第一步：识别变更类型

判断是否为"涉及自身的修改"：

- SOUL.md、IDENTITY.md、AGENTS.md、TOOLS.md、MEMORY.md 等核心身份/行为文件
- openclaw.json 配置变更（agents、tools、gateway 等关键字段）
- 新增/删除/修改技能（skills/）
- Prompt 模板、系统引导文件的变更
- 插件配置变更

> **注意**：普通对话、查询、搜索等不需要走此流程。只有**写操作**（修改文件、改配置）才触发。

---

### 第二步：隔离验证（Clone-01）

使用 `sessions_spawn` 在 Clone-01 中执行变更验证：

**会话标签**：`safe-mod-test`
**工作目录**：`/workspace/clone`
**运行模式**：`run`（一次性任务）
**超时**：300 秒

Spawn 前准备验证脚本，写入 `/workspace/clone/verify_task.sh`：

```bash
#!/bin/bash
# 1. 备份当前状态
cp /workspace/clone/SOUL.md /workspace/clone/.backup_SOUL.md
# 2. 执行变更（从主实例传来的具体修改内容）
# 3. 验证结果
cat > /workspace/clone/VERIFY_RESULT.md << 'EOF'
# 验证结果
状态: PASS/FAIL
变更内容: ...
语法检查: ...
加载测试: ...
问题: ...
EOF
```

---

### 第三步：分析 Clone-01 的验证结果

收到 Clone-01 完成通知后，检查 `/workspace/clone/VERIFY_RESULT.md`：

- **PASS** → 向用户报告变更内容 + 风险评估，询问是否应用到主实例
- **FAIL** → 向用户报告具体问题，告知主实例**未做任何修改**

---

### 第四步：用户确认后执行

用户确认后，才能用 `edit`/`write` 工具修改主实例文件。

---

## 变更分级

| 级别 | 类型 | 示例 | 风险 |
|------|------|------|------|
| 🔴 高危 | 删除核心规则、破坏 AGENTS.md | 移除所有行为约束 | 不可逆 |
| 🟡 中危 | 修改 SOUL.md、IDENTITY.md | 改变性格/语气 | 可逆但影响大 |
| 🟢 低危 | 更新 TOOLS.md、添加备注 | 补充工具备注 | 风险小 |

---

## 常驻子 Agent

Clone-01 会话可保持为 `thread=true` 的持久会话：

- **session key**：`agent:main:subagent:de22433e-cd9f-4bc1-ba87-c5ab31fb343e`
- **通信方式**：`sessions_send(sessionKey, message)`
- **结果回收**：等待子 Agent 的 `subagent_announce` 完成事件

---

## 验证检查清单（每次必查）

- [ ] 变更文件存在且语法正确
- [ ] SOUL.md 核心规则仍然有效
- [ ] IDENTITY.md 身份定义完整
- [ ] 无破坏性的内容删除
- [ ] 下次启动能正常加载

---

## 错误处理

- Clone-01 运行失败 → 报告错误，主实例不修改
- 验证脚本异常 → 报告异常，标记为 FAIL
- 超时 → 报告超时，主实例不修改
