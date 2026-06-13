---
paths:
  - "config/hermes/**"
---

# Hermes Agent Setup

`config/hermes/config.yaml` は `~/.hermes/config.yaml` にシンボリックリンクされる。
`~/.hermes/.env`（APIキー）は git 管理外。テンプレートから作成する:

```bash
pip install hermes-agent  # または pipx install hermes-agent
cp config/hermes/.env.example ~/.hermes/.env
# ~/.hermes/.env にAPIキーを設定
```

モデルやターミナルバックエンドの変更:
```bash
hermes config set model anthropic/claude-sonnet-4-6
hermes config set terminal.backend local
```

## Profiles

プロファイルは独立 Git リポジトリで管理（dotfiles 非対象）。`hermes profile install github.com/toutatsu/toutatsu-agent` でインストール。
