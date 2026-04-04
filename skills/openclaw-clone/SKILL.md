---
name: openclaw-clone
description: >
  Clone, configure, and manage multiple OpenClaw instances on the same server.
  Use when (1) Creating new OpenClaw clone instances, (2) Starting/stopping clone gateways,
  (3) Configuring models or settings for clones, (4) Fixing clone connection issues.
  Triggers on phrases like clone openclaw, create new instance, start clone, configure clone, add another openclaw.
---

# OpenClaw Clone Management

## Core Concept

OpenClaw runs as a gateway process. Multiple instances can run on the same server if each has a unique port and config. **Critical constraint**: `openclaw gateway` commands are intercepted by the systemd user service — you must invoke the Node.js binary directly with environment variables.

## Instance Layout

```
/root/.openclaw-clone01/   ← instance "clone01"
    openclaw.json
    canvas/
    logs/
/root/.openclaw-clone02/   ← instance "clone02"
    openclaw.json
    canvas/
    logs/
...
```

## Quick Reference

| Action | Command |
|--------|---------|
| Create clone | `cp -r /root/.openclaw /root/.openclaw-cloneXX` then edit openclaw.json |
| Start instance | Env vars + node binary (see below) |
| Stop instance | `kill <pid>` |
| Restart | Kill + start with same command |

## Node Binary Paths (DO NOT use `openclaw` CLI directly)

```
NODE_BIN=/root/.nvm/versions/node/v22.22.2/bin/node
OPENCLAW_DIST=/root/.local/share/pnpm/global/5/.pnpm/openclaw@2026.3.28_@napi-rs+canvas@0.1.97/node_modules/openclaw/dist/index.js
```

## Start a Clone Instance

```bash
OPENCLAW_STATE_DIR=/root/.openclaw-cloneXX \
OPENCLAW_CONFIG_PATH=/root/.openclaw-cloneXX/openclaw.json \
node '$OPENCLAW_DIST' gateway --port YYYYY > /tmp/cloneXX.log 2>&1 &
echo "PID: $!"
```

Check with: `ss -tlnp | grep YYYYY`

## Create a New Clone

1. Duplicate config:
```bash
cp -r /root/.openclaw /root/.openclaw-clone03
```

2. Edit `openclaw.json` — change these fields:
```json
{
  "gateway": {
    "port": 19003,
    "controlUi": {
      "allowedOrigins": ["*"],
      "allowInsecureAuth": true,
      "dangerouslyDisableDeviceAuth": true
    },
    "auth": {
      "mode": "token",
      "token": "clone03-token-2026"
    }
  }
}
```

3. Start it using the start command above with port 19003

## Configure Model Provider

Add `models.providers` block to `openclaw.json`:

```json
{
  "models": {
    "providers": {
      "minimax": {
        "baseUrl": "https://api.minimaxi.com/anthropic",
        "apiKey": "YOUR_API_KEY",
        "api": "anthropic-messages",
        "models": [
          { "id": "MiniMax-M2.7", "name": "MiniMax M2.7" },
          { "id": "MiniMax-M2.5", "name": "MiniMax M2.5" }
        ]
      }
    },
    "mode": "merge"
  }
}
```

## Common Issues

**"device identity" error in browser**: Add `"dangerouslyDisableDeviceAuth": true` to `gateway.controlUi`

**"gateway token mismatch"**: Verify the token in the URL/UI matches `gateway.auth.token` in openclaw.json

**`openclaw gateway` restarts wrong instance**: Always use the node binary directly, never the `openclaw` CLI for starting clones

**Port already in use**: Another process is on that port. Run `ss -tlnp | grep PORT` to find it

## List Running Instances

```bash
ss -tlnp | grep openclaw-gatewa
```

Shows all running gateway processes and their ports.
