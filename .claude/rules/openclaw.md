---
paths:
  - "config/openclaw/**"
---

# OpenClaw Setup

`config/openclaw/openclaw.json.example` はテンプレート (シンボリックリンク非対象)。
`~/.openclaw/openclaw.json` は `openclaw onboard` が自動生成・更新するため、直接管理しない。
トークン (`gateway.auth.token`) が含まれるため git 管理対象外。

新環境セットアップ手順:
```bash
npm install -g openclaw@latest
openclaw onboard --install-daemon
# 必要に応じてテンプレートを参考に ~/.openclaw/openclaw.json を調整
```
