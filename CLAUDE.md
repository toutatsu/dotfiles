# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

Personal dotfiles managed via symlinks. The repo contains shell configs, editor settings, and terminal tool configs deployed to `$HOME` via `install.sh`.

残タスク（機能追加系）の仕様書は `docs/improvement-plan.md` を参照。着手前に必ず読むこと。

ツール固有のセットアップ手順（DeepAgents / Hermes / OpenClaw / ntfy-claude）は `.claude/rules/` 配下に分割されており、該当パスのファイル編集時に自動ロードされる。

## Deployment

```bash
make           # Symlink all dotfiles to $HOME (backs up existing files as *.pre-dotfiles)
make uninstall # Remove symlinks and restore backups
```

Or directly:

```bash
./install.sh
./install.sh --uninstall
```

`install.sh` uses its own directory as the source (safe to run from anywhere).

All files are under `config/`. `mytheme.zsh-theme` is deployed to `~/.oh-my-zsh/themes/` (skipped if oh-my-zsh is not installed).

## Directory Structure

```
config/
  claude/
    CLAUDE.md              → ~/.claude/CLAUDE.md
    settings.json          → ~/.claude/settings.json
    claude.json.example    — ~/.claude.json のテンプレート (シンボリックリンク非対象)
    .env.example           — Claude Code 用 MCP トークン設定テンプレート (シンボリックリンク非対象)
    agents/                → ~/.claude/agents/ (ディレクトリごとシンボリックリンク)
    skills/                → ~/.claude/skills/ (ディレクトリごとシンボリックリンク)
    skill-template/        — スキル作成用テンプレート (シンボリックリンク非対象、skills/ に置くと実スキルとして読み込まれるため)
  git/    → .gitconfig, .gitignore, .gitattributes
  shell/  → .profile, .inputrc
    bin/      → ~/.local/bin (ファイルごとシンボリックリンク、*.example は除外)
      ntfy-claude          → ~/.local/bin/ntfy-claude (ntfy 通知スクリプト)
      ntfy-claude-hook     → ~/.local/bin/ntfy-claude-hook (Claude Code フック用、ntfy-claude を呼び出す)
      ntfy-claude.env.example — ntfy 接続先設定テンプレート（~/.config/ntfy-claude.env に配置、非対象）
      claude-statusline    → ~/.local/bin/claude-statusline (Claude Code statusLine 用スクリプト)
      bitlocker-mount      → ~/.local/bin/bitlocker-mount (dislocker による BitLocker マウント)
    functions/ → ~/.local/share/dotfiles/functions (source 専用、.profile が自動読み込み)
    bash/ → .bash_profile, .bashrc
    zsh/  → .zshrc, mytheme.zsh-theme
  tmux/   → .tmux.conf
  vim/    → .vimrc
  vscode/
    settings.json          → ~/.config/Code/User/settings.json（ローカル起動）/ ~/.vscode-server/data/Machine/settings.json（Remote/Tunnel接続される側）
  editorconfig/
    .editorconfig          → ~/.editorconfig
  opencode/
    opencode.jsonc         → ~/.config/opencode/opencode.jsonc
    .env.example           — opencode 用 API キー設定テンプレート (シンボリックリンク非対象)
    tui.json               → ~/.config/opencode/tui.json
    AGENTS.md              → ~/.config/opencode/AGENTS.md
    agents/                → ~/.config/opencode/agents/ (ディレクトリごとシンボリックリンク)
    skills/                → ~/.config/opencode/skills/ (ディレクトリごとシンボリックリンク)
    tools/                 → ~/.config/opencode/tools/ (ディレクトリごとシンボリックリンク)
  deepagents/
    config.toml            → ~/.deepagents/config.toml
    .mcp.json              → ~/.deepagents/.mcp.json
    AGENTS.md              → ~/.deepagents/agent/AGENTS.md
    .mcp.json.example      — .mcp.json の設定例テンプレート (シンボリックリンク非対象)
    .env.example           — ~/.deepagents/.env のテンプレート (シンボリックリンク非対象)
    agents/                → ~/.deepagents/agent/agents/ (ディレクトリごとシンボリックリンク)
    skills/                → ~/.deepagents/agent/skills/ (ディレクトリごとシンボリックリンク)
  codex/
    config.toml            → ~/.codex/config.toml
    .env.example           — Codex CLI 用 API キー設定テンプレート (シンボリックリンク非対象)
    AGENTS.md              → ~/.codex/AGENTS.md
    skills/                → ~/.codex/skills/ (ディレクトリごとシンボリックリンク)
  hermes/
    config.yaml            → ~/.hermes/config.yaml
    SOUL.md                → ~/.hermes/SOUL.md (エージェント個性・口調の定義、全メッセージに注入される)
    .env.example           — Hermes Agent 用 API キー設定テンプレート (シンボリックリンク非対象)
    AGENTS.md              → ~/.hermes/AGENTS.md
    profiles/              — 独立 Git リポジトリで管理（hermes profile install で導入）
  openclaw/
    openclaw.json.example  — ~/.openclaw/openclaw.json のテンプレート (シンボリックリンク非対象)
  ssh/
    config.example         — ~/.ssh/config のテンプレート (シンボリックリンク非対象)
  termux/
    termux.properties      → ~/.termux/termux.properties (Termux 環境のみ)
```

## Architecture

**Shell layers:**
- `config/shell/.profile` — shared env vars, SSH agent init, `trash()` utility; sourced by both shells
- `config/shell/bash/.bashrc` — bash-specific config, sources `.profile`, defines colorized prompt
- `config/shell/zsh/.zshrc` — zsh config via oh-my-zsh with `mytheme` theme and `vi-mode`/`git` plugins
- `config/shell/zsh/mytheme.zsh-theme` — custom prompt using 256-color palette and box-drawing characters; deployed to `~/.oh-my-zsh/themes/`

**Vi-mode is configured at three levels:**
1. `.inputrc` — readline vi mode (affects bash and other readline apps)
2. `.zshrc` — oh-my-zsh `vi-mode` plugin
3. `.vimrc` — vim keybindings (`;j` to exit insert/visual/command mode, `<Esc><Esc>` to clear search)

**Git aliases** in `.gitconfig`: `co` (checkout), `br` (branch), `st` (status), `d` (diff), `loggraph` (graph log with colors), `tree` (compact graph log). Pull strategy is fast-forward only. `[user]` identity is intentionally omitted — set per-repo via `git config --local user.name/email` or environment variables.

**Tmux** uses `screen-256color` terminal type.

## oh-my-zsh Setup

oh-my-zsh is not included in this repo and must be installed separately before sourcing `.zshrc`. The `mytheme.zsh-theme` file needs to be copied/linked into `~/.oh-my-zsh/themes/`.

## Claude Code Setup

`config/claude/CLAUDE.md` is symlinked to `~/.claude/CLAUDE.md` — global instructions applied to all projects (token efficiency, subagent usage, response style).
`config/claude/settings.json` is managed here and symlinked to `~/.claude/settings.json`.
Key settings: `language: japanese`, allowed tools: `Bash(git *)`, `Bash(make *)`.
ステータスラインは `config/shell/bin/claude-statusline`（`~/.local/bin` にリンク）を `statusLine.command` から呼び出す。

MCP server configs and credentials live in `~/.claude.json` (not version-controlled).
Reason: `~/.claude.json` contains API tokens alongside server URLs, so it must stay out of git.
Template: `config/claude/claude.json.example`

### MCP Servers

`config/shell/bin/claude-mcp-setup`（`~/.local/bin/claude-mcp-setup` にリンク）でまとめて登録できる。`~/.env` に `GITHUB_PERSONAL_ACCESS_TOKEN` を設定してから実行する。冪等（登録済みはスキップ）。

```bash
claude-mcp-setup
```

手動で追加する場合:
```bash
claude mcp add --transport http github https://api.githubcopilot.com/mcp/
claude mcp list
```

Scopes: `--scope user`（全プロジェクト共通）、`--scope local`（現在プロジェクトのみ、デフォルト）

### Agents

`config/claude/agents/` is symlinked to `~/.claude/agents/` and available across all projects.

| Agent | Description |
|-------|-------------|
| `code-reviewer` | git diff でコードを確認し、セキュリティ・品質・可読性の観点でレビューする |

## ディレクトリリンクによるファイル混入について

`dir_links` エントリ（`config/codex/skills/` など）はディレクトリごとシンボリックリンクするため、**外部ツールがリンク先に書き込んだファイルがリポジトリ内に直接現れる**。

確認済みの混入例:
- `config/codex/skills/.system/` — Codex CLI が自動インストールするシステムスキル
- `config/shell/bin/claude` — Claude Code インストーラーが `PATH` 内 `bin/` に書き込んだリンク

対策:
- 混入しうるパターンはリポジトリ直下の `.gitignore` に追加済み
- 新しいツールを追加した後は `git status` で意図しないファイルが混入していないか確認する
- 根本的な解決策はディレクトリリンクをやめてファイルごとリンク（`spread_dirs` 方式）に移行することだが、新スキル追加のたびに `install.sh` 更新が必要になるためトレードオフがある
