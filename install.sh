#!/bin/bash

install=true

while [[ $# -gt 0 ]]; do
  case "$1" in
    --uninstall)
      install=false
      shift
      ;;
    *)
      echo "Usage: $0 [--uninstall]"
      exit 1
      ;;
  esac
done

# スクリプト自身のディレクトリ（どこから実行しても正しく解決される）
source_dir="$(cd "$(dirname "$0")" && pwd)"

# "リポジトリ内の相対パス:配置先の絶対パス" 形式
files=(
  "config/shell/.profile:$HOME/.profile"
  "config/shell/.inputrc:$HOME/.inputrc"
  "config/shell/bash/.bash_profile:$HOME/.bash_profile"
  "config/shell/bash/.bashrc:$HOME/.bashrc"
  "config/shell/zsh/.zshrc:$HOME/.zshrc"
  "config/git/.gitconfig:$HOME/.gitconfig"
  "config/git/.gitignore:$HOME/.gitignore"
  "config/tmux/.tmux.conf:$HOME/.tmux.conf"
  "config/vim/.vimrc:$HOME/.vimrc"
  "config/shell/zsh/mytheme.zsh-theme:$HOME/.oh-my-zsh/themes/mytheme.zsh-theme"
)

# ---

process_file() {
  local source_file="$1"
  local target_file="$2"
  local target_dir
  target_dir="$(dirname "$target_file")"

  echo "------------------------------------------------"
  echo "checking : $target_file"

  if [ "$install" = true ]; then

    if [ ! -d "$target_dir" ]; then
      echo "skip     : $target_file (directory not found: $target_dir)"
      return
    fi

    if [ -L "$target_file" ]; then
      echo "skip     : symlink already exists"
      return
    fi

    if [ -f "$target_file" ]; then
      echo "backup   : $target_file -> $target_file.dotfiles.old"
      mv "$target_file" "$target_file.dotfiles.old"
    fi

    echo "link     : $source_file -> $target_file"
    ln -s "$source_file" "$target_file"

  else

    if [ -L "$target_file" ]; then
      echo "unlink   : $target_file"
      rm "$target_file"
    fi

    if [ -f "$target_file.dotfiles.old" ]; then
      echo "restore  : $target_file.dotfiles.old -> $target_file"
      mv "$target_file.dotfiles.old" "$target_file"
    fi

  fi
}

for entry in "${files[@]}"; do
  src_rel="${entry%%:*}"
  target_file="${entry##*:}"
  process_file "$source_dir/$src_rel" "$target_file"
done

echo "------------------------------------------------"
echo "done."
