---
paths:
  - "config/shell/bin/ntfy-claude*"
---

# ntfy-claude Setup

`config/shell/bin/ntfy-claude` は ntfy サーバーへ通知を送るスクリプト。
`config/shell/bin/ntfy-claude-hook` は Claude Code フック（`Stop` / `Notification` / `PermissionRequest`）から呼ばれ、stdin の JSON を整形して `ntfy-claude` 経由で通知する。どちらも `install.sh` で `~/.local/bin` にリンクされる。
接続先（`NTFY_CLAUDE_URL` / `NTFY_CLAUDE_AUTH`）は `~/.config/ntfy-claude.env` で設定する（必須、テンプレート: `config/shell/bin/ntfy-claude.env.example`）。`NTFY_CLAUDE_URL` が未設定の場合はエラーメッセージを stderr に出力して exit 1 する。
Stop フックは `async: true` で非同期実行されるためレスポンスをブロックしない。
