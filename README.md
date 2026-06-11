# dotfiles

Personal dotfiles for shell, editor, and terminal tools, managed via symlinks.

## Setup

```bash
git clone git@github.com:toutatsu/dotfiles.git
cd dotfiles
make
```

`make` creates symlinks from this repo to `$HOME`. Existing files are backed up as `*.pre-dotfiles`.

### oh-my-zsh (required for zsh)

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

After installing oh-my-zsh, re-run `make` to deploy `mytheme.zsh-theme`.

### Environment Variables

API keys and tokens are not version-controlled. Copy the example files and fill in your values:

```bash
# 共通設定
cp .env.example ~/.env

# サービス固有
cp config/deepagents/.env.example ~/.deepagents/.env
cp config/codex/.env.example ~/.codex/.env
cp config/opencode/.env.example ~/.config/opencode/.env
cp config/hermes/.env.example ~/.hermes/.env
cp config/shell/bin/ntfy-claude.env.example ~/.config/ntfy-claude.env
```

## Uninstall

```bash
make uninstall
```

Removes symlinks and restores backed-up files.

## Structure

```
config/
  claude/        Claude Code (CLAUDE.md, settings.json, agents/, skills/)
  codex/         Codex CLI (config.toml, AGENTS.md, skills/)
  deepagents/    DeepAgents CLI (config.toml, .mcp.json, agents/, skills/)
  editorconfig/  .editorconfig
  git/           .gitconfig, .gitignore, .gitattributes
  hermes/        Hermes Agent (config.yaml, SOUL.md, AGENTS.md)
  openclaw/      OpenClaw (テンプレートのみ)
  opencode/      opencode (opencode.jsonc, tui.json, agents/, skills/, tools/)
  shell/         .profile, .inputrc
    bash/        .bash_profile, .bashrc
    bin/         ~/.local/bin に配置するスクリプト群
    functions/   .profile が読み込むシェル関数
    zsh/         .zshrc, mytheme.zsh-theme
  ssh/           ~/.ssh/config のテンプレート
  termux/        termux.properties (Termux 環境のみ)
  tmux/          .tmux.conf
  vim/           .vimrc
  vscode/        settings.json
```

See `CLAUDE.md` for the full file-by-file link map.
