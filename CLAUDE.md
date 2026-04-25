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
    agents/
      code-reviewer.md     → ~/.claude/agents/code-reviewer.md
  git/    → .gitconfig, .gitignore, .gitattributes
  shell/  → .profile, .inputrc
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
    tui.json               → ~/.config/opencode/tui.json
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

### MCP Servers

Add MCP servers manually after install. Known servers:

```bash
# GitHub (requires GITHUB_PERSONAL_ACCESS_TOKEN env var)
claude mcp add --transport http github https://api.githubcopilot.com/mcp/

# 登録済みサーバー一覧
claude mcp list
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
