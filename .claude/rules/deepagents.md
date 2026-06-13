---
paths:
  - "config/deepagents/**"
---

# DeepAgents CLI Setup

`config/deepagents/config.toml` は `~/.deepagents/config.toml` にシンボリックリンクされる。
`~/.deepagents/.env`（APIキー）は git 管理外。テンプレートから作成する:

```bash
uv tool install deepagents-cli
cp config/deepagents/.env.example ~/.deepagents/.env
# ~/.deepagents/.env にAPIキーを設定
```

ローカルの llama.cpp API を使う場合は `llama-server` をポート 8080 で起動しておく。
