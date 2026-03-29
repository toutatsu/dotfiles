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

Managed files: `.profile`, `.zshrc`, `.bashrc`, `.inputrc`, `.tmux.conf`, `.vimrc`, `.gitconfig`
Special placement: `mytheme.zsh-theme` → `~/.oh-my-zsh/themes/` (skipped if oh-my-zsh is not installed)

## Architecture

**Shell layers:**
- `.profile` — shared env vars, SSH agent init, `trash()` utility; sourced by both shells
- `.bashrc` — bash-specific config, sources `.profile`, defines colorized prompt
- `.zshrc` — zsh config via oh-my-zsh with `mytheme` theme and `vi-mode`/`git` plugins
- `mytheme.zsh-theme` — custom prompt using 256-color palette and box-drawing characters; must be placed in `~/.oh-my-zsh/themes/` manually

**Vi-mode is configured at three levels:**
1. `.inputrc` — readline vi mode (affects bash and other readline apps)
2. `.zshrc` — oh-my-zsh `vi-mode` plugin
3. `.vimrc` — vim keybindings (`;j` to exit insert/visual/command mode, `<Esc><Esc>` to clear search)

**Git aliases** (`loggraph`, `tree`) are in `.gitconfig`. Pull strategy is fast-forward only.

**Tmux** uses `screen-256color` terminal type.

## oh-my-zsh Setup

oh-my-zsh is not included in this repo and must be installed separately before sourcing `.zshrc`. The `mytheme.zsh-theme` file needs to be copied/linked into `~/.oh-my-zsh/themes/`.
