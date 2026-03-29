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
  git/    → .gitconfig, .gitignore
  shell/  → .profile, .inputrc
    bash/ → .bash_profile, .bashrc
    zsh/  → .zshrc, mytheme.zsh-theme
  tmux/   → .tmux.conf
  vim/    → .vimrc
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

**Git aliases** (`loggraph`, `tree`) are in `.gitconfig`. Pull strategy is fast-forward only.

**Tmux** uses `screen-256color` terminal type.

## oh-my-zsh Setup

oh-my-zsh is not included in this repo and must be installed separately before sourcing `.zshrc`. The `mytheme.zsh-theme` file needs to be copied/linked into `~/.oh-my-zsh/themes/`.
