---
name: daily-clawhub-learning
description: "每日凌晨学习, 定时学习, clawhub学习报告, 自动学习 — 每天凌晨3点自动从ClawHub学习技能和插件，生成学习报告并存入 memory/。触发条件：crontab定时触发或手动调用脚本。"
---

# 每日 ClawHub 定时学习技能

## Overview

每天凌晨 3:00 自动从 ClawHub（clawhub.ai）抓取技能和插件数据，进行结构化分析，生成学习报告并存入 `memory/YYYY-MM-DD-clawhub-report.md`。

## 工作流程

1. **数据抓取**：使用 clawhub CLI 和 web scraping 获取最新技能/插件列表
2. **数据分析**：按类型、下载量、触发词等维度分析
3. **报告生成**：输出结构化报告（技能分析、插件分析、对比、建议）
4. **存储**：存入 `memory/YYYY-MM-DD-clawhub-report.md`

## 触发方式

- **自动**：crontab 每日 03:00 执行
- **手动**：`bash /root/.openclaw/workspace/skills/daily-clawhub-learning/scripts/learn.sh`

## 输出

- 报告路径：`memory/YYYY-MM-DD-clawhub-report.md`
- 覆盖内容：
  - 技能总量与分类统计
  - 热门技能 TOP20（按下载量）
  - 插件总量与分类
  - 技能 vs 插件 对比分析
  - 对 AgentHub 项目的改进建议
  - 重点技能深入分析（SKILL.md 结构研究）

## 时间窗口

学习时间：03:00 ~ 07:00（4小时）
报告生成：07:00 前完成
