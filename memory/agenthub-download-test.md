# AgentHub 插件技能下载测试 - 2026-04-03 16:20 GMT+8

## 测试结果

### setup.html
- **状态**: ✅ 可访问（HTTP 200）
- **URL**: http://49.233.249.103/setup.html
- **内容**: AgentHub × OpenClaw 接入向导页面，包含配置表单、提示词生成、下载按钮

### 静态资源列表

服务器本地路径 `/var/www/agenthub/static/`:
```
static/
├── channel/
│   ├── index.js  (9956 bytes)
│   └── index.ts  (8973 bytes)
└── skills/
    └── agenthub/
        └── SKILL.md  (2806 bytes, 125行)
```

### 可下载文件（远程测试）

| 文件 | URL | 状态 | 说明 |
|------|-----|------|------|
| SKILL.md | http://49.233.249.103/static/skills/agenthub/SKILL.md | ✅ 200 OK | 技能文件，可正常下载 |
| index.js | http://49.233.249.103/static/channel/index.js | ✅ 200 OK | Channel 插件主文件 |
| index.ts | http://49.233.249.103/static/channel/index.ts | ✅ 200 OK | Channel 插件 TypeScript 源码 |
| /static/channel/ | http://49.233.249.103/static/channel/ | ❌ 403 Forbidden | 目录索引被禁用 |
| /static/plugins/ | http://49.233.249.103/static/plugins/ | ❌ setup.html redirect | 路径不存在 |
| .tar.gz 文件 | http://49.233.249.103/static/skills/daily-clawhub-learning.tar.gz | ❌ setup.html redirect | 不存在，返回 setup.html |

### setup.html 中的动态下载链接

setup.html 生成的下载链接格式（用户填入服务器地址后）:
- **技能文件**: `{server}/static/skills/agenthub/SKILL.md` ✅ 实际可访问
- **插件目录**: `{server}/static/channel/` ❌ 返回 403
- **完整插件包**: `{server}/static/channel/` ❌ 同上，无实际 .zip 文件

## 发现的问题

### 1. 🔴 严重：插件目录无法下载
- `/static/channel/` 返回 **403 Forbidden**
- nginx 配置中未开启 `autoindex on`，导致目录不可浏览
- setup.html 的插件下载按钮实际指向此路径，用户无法下载插件文件

### 2. 🟡 中等：setup.html 引导用户下载不存在的 .tar.gz 文件
- 用户测试任务中使用的路径（如 `agenthub-openclaw-channel.tar.gz`、`daily-clawhub-learning.tar.gz`）**均不存在**
- 这些路径返回 setup.html（疑似 nginx fallback 到 index）

### 3. 🟡 中等：缺少打包好的插件包
- setup.html 提到"完整插件包（channel-agenthub 目录）"下载，但链接指向目录而非文件
- 用户无法一键下载整个 `channel-agenthub` 目录

### 4. 🟢 轻微：setup.html 默认 SERVER 常量是 localhost:3000
- 用户首次打开时，默认服务器地址为 `http://localhost:3000`，需要手动修改

## 建议

### 高优先级
1. **为 /static/channel/ 创建可下载的打包文件**：
   ```bash
   # 方案A：打包成 tar.gz
   cd /var/www/agenthub/static/channel
   tar -czvf ../channel-agenthub.tar.gz .
   # 然后链接改为 /static/channel-agenthub.tar.gz

   # 方案B：nginx 开启 autoindex（不推荐，生产环境）
   location /static/channel/ {
       autoindex on;
   }
   ```

2. **创建完整的 channel-agenthub 目录打包**：
   用户需要整个目录结构（src/、配置文件等），建议打包为：
   - `/static/channel-agenthub.tar.gz` → 完整插件目录

### 中优先级
3. **删除或修正 setup.html 中对不存在 .tar.gz 的引用**，避免用户困惑
4. **提供明确的下载文件名**（不要只指向目录），让用户知道具体下载什么

### 低优先级
5. **考虑将 index.js/index.ts 合并为标准插件格式**，增加 package.json、README.md 等完整插件元数据

## 文件大小汇总

| 文件 | 大小 |
|------|------|
| SKILL.md | 2806 bytes |
| index.js | 9956 bytes |
| index.ts | 8973 bytes |
| **合计** | ~21 KB |
