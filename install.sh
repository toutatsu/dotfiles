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

# $HOME へ配置する dotfiles
dotfiles=(
  .profile
  .zshrc
  .bashrc
  .inputrc
  .tmux.conf
  .vimrc
  .gitconfig
)

# 配置先が $HOME 以外のファイル（"ファイル名:配置先の絶対パス" 形式）
special_files=(
  "mytheme.zsh-theme:$HOME/.oh-my-zsh/themes/mytheme.zsh-theme"
)

# ---

process_file() {
  local source_file="$1"
  local target_file="$2"

  echo "------------------------------------------------"
  echo "checking : $target_file"

  if [ "$install" = true ]; then

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

# $HOME へ配置
for dotfile in "${dotfiles[@]}"; do
  process_file "$source_dir/$dotfile" "$HOME/$dotfile"
done

# 特定ディレクトリへ配置
for entry in "${special_files[@]}"; do
  src_name="${entry%%:*}"
  target_file="${entry##*:}"
  target_dir="$(dirname "$target_file")"

  if [ "$install" = true ] && [ ! -d "$target_dir" ]; then
    echo "------------------------------------------------"
    echo "skip     : $src_name (directory not found: $target_dir)"
    continue
  fi

  process_file "$source_dir/$src_name" "$target_file"
done

echo "------------------------------------------------"
echo "done."
