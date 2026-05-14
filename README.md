# dotfiles

Personal dotfiles for shell, editor, and terminal tools, managed via symlinks.

## Setup

```bash
git clone git@github.com:toutatsu/dotfiles.git
cd dotfiles
make
```

`make` creates symlinks from this repo to `$HOME`. Existing files are backed up as `*.dotfiles.old`.

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
```

## Uninstall

```bash
make uninstall
```

Removes symlinks and restores backed-up files.

## Structure

```
config/
  git/         .gitconfig, .gitignore
  shell/       .profile, .inputrc
    bash/      .bash_profile, .bashrc
    zsh/       .zshrc, mytheme.zsh-theme
  tmux/        .tmux.conf
  vim/         .vimrc
```
