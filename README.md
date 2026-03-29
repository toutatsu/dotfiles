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
