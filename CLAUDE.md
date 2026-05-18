# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

Personal dotfiles managed via symlinks. The repo contains shell configs, editor settings, and terminal tool configs deployed to `$HOME` via `link.sh`.

## Deployment

```bash
make           # Symlink all dotfiles to $HOME (backs up existing files as *.dotfiles.old)
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
      code-reviewer.md
    skills/                → ~/.claude/skills/ (ディレクトリごとシンボリックリンク)
      commit/SKILL.md      — git コミット作成（manual invoke のみ）
      pr/SKILL.md          — GitHub PR 作成（manual invoke のみ）
      search-docs/SKILL.md — ライブラリドキュメント検索（自動起動あり）
      fix-issue/SKILL.md   — GitHub issue 番号指定で修正（manual invoke のみ）
      explain-code/SKILL.md — アナロジーと ASCII 図でコードを説明（自動起動あり）
      pr-review/           — PR diff を取得してコードレビュー（manual invoke / 自動起動あり）
        SKILL.md           — スキル本体（context: fork + agent: code-reviewer）
        template.md        — レビューコメントの記述テンプレート
        examples/sample.md — 期待するレビュー出力のサンプル
        scripts/validate.sh — PR 作成前の事前チェックスクリプト
      _template/SKILL.md   — 新規スキル作成用テンプレート
  git/    → .gitconfig, .gitignore, .gitattributes
  shell/  → .profile, .inputrc
    bin/      → ~/.local/bin (ディレクトリごとシンボリックリンク)
    functions/ → ~/.local/share/dotfiles/functions (source 専用、.profile が自動読み込み)
    bash/ → .bash_profile, .bashrc
    zsh/  → .zshrc, mytheme.zsh-theme
  tmux/   → .tmux.conf
  vim/    → .vimrc
  vscode/
    settings.json          → ~/.config/Code/User/settings.json
  editorconfig/
    .editorconfig          → ~/.editorconfig
  opencode/
    opencode.jsonc         → ~/.config/opencode/opencode.jsonc
    .env.example           — opencode 用 API キー設定テンプレート (シンボリックリンク非対象)
    tui.json               → ~/.config/opencode/tui.json
    AGENTS.md              → ~/.config/opencode/AGENTS.md
    agents/                → ~/.config/opencode/agents/ (ディレクトリごとシンボリックリンク)
      code-reviewer.md
    skills/                → ~/.config/opencode/skills/ (ディレクトリごとシンボリックリンク)
      _template/SKILL.md   — 新規スキル作成用テンプレート
    tools/                 → ~/.config/opencode/tools/ (ディレクトリごとシンボリックリンク)
      git_summary.ts       — git コミットログ取得ツール
      file_stats.ts        — ファイル統計情報取得ツール
      add.ts / add.py      — 2つの数値を足し算するツール（Python ラッパー）
      word_count.ts / word_count.py — テキストの行数・単語数・文字数をカウントするツール（Python ラッパー）
  deepagents/
    config.toml            → ~/.deepagents/config.toml
    .mcp.json              → ~/.deepagents/.mcp.json
    AGENTS.md              → ~/.deepagents/agent/AGENTS.md
    .mcp.json.example      — .mcp.json の設定例テンプレート (シンボリックリンク非対象)
    .env.example           — ~/.deepagents/.env のテンプレート (シンボリックリンク非対象)
    agents/                → ~/.deepagents/agent/agents/ (ディレクトリごとシンボリックリンク)
      researcher/AGENTS.md
      code-writer/AGENTS.md
      git-assistant/AGENTS.md
      _template/AGENTS.md  — 新規サブエージェント作成用テンプレート
    skills/                → ~/.deepagents/agent/skills/ (ディレクトリごとシンボリックリンク)
      _template/SKILL.md   — 新規スキル作成用テンプレート
  codex/
    config.toml            → ~/.codex/config.toml
    .env.example           — Codex CLI 用 API キー設定テンプレート (シンボリックリンク非対象)
    AGENTS.md              → ~/.codex/AGENTS.md
    skills/                → ~/.codex/skills/ (ディレクトリごとシンボリックリンク)
      _template/SKILL.md   — 新規スキル作成用テンプレート
  hermes/
    config.yaml            → ~/.hermes/config.yaml
    SOUL.md                → ~/.hermes/SOUL.md (エージェント個性・口調の定義、全メッセージに注入される)
    .env.example           — Hermes Agent 用 API キー設定テンプレート (シンボリックリンク非対象)
    AGENTS.md              → ~/.hermes/AGENTS.md
    profiles/
      tt-agent/
        config.yaml        → ~/.hermes/profiles/tt-agent/config.yaml
        SOUL.md            → ~/.hermes/profiles/tt-agent/SOUL.md
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

MCP server configs and credentials live in `~/.claude.json` (not version-controlled).
Reason: `~/.claude.json` contains API tokens alongside server URLs, so it must stay out of git.
Template: `config/claude/claude.json.example`

### MCP Servers

Add MCP servers manually after install. Known servers:

```bash
# GitHub (requires GITHUB_PERSONAL_ACCESS_TOKEN env var)
claude mcp add --transport http github https://api.githubcopilot.com/mcp/

# 登録済みサーバー一覧
claude mcp list
```

Scopes: `--scope user`（全プロジェクト共通）、`--scope local`（現在プロジェクトのみ、デフォルト）

## DeepAgents CLI Setup

`config/deepagents/config.toml` は `~/.deepagents/config.toml` にシンボリックリンクされる。
`~/.deepagents/.env`（APIキー）は git 管理外。テンプレートから作成する:

```bash
uv tool install deepagents-cli
cp config/deepagents/.env.example ~/.deepagents/.env
# ~/.deepagents/.env にAPIキーを設定
```

ローカルの llama.cpp API を使う場合は `llama-server` をポート 8080 で起動しておく。

## Hermes Agent Setup

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

## OpenClaw Setup

`config/openclaw/openclaw.json.example` はテンプレート (シンボリックリンク非対象)。
`~/.openclaw/openclaw.json` は `openclaw onboard` が自動生成・更新するため、直接管理しない。
トークン (`gateway.auth.token`) が含まれるため git 管理対象外。

新環境セットアップ手順:
```bash
npm install -g openclaw@latest
openclaw onboard --install-daemon
# 必要に応じてテンプレートを参考に ~/.openclaw/openclaw.json を調整
```

### Agents

`config/claude/agents/` is symlinked to `~/.claude/agents/` and available across all projects.

| Agent | Description |
|-------|-------------|
| `code-reviewer` | git diff でコードを確認し、セキュリティ・品質・可読性の観点でレビューする |
