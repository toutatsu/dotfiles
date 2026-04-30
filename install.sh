#!/bin/bash

install=true

while [[ $# -gt 0 ]]; do
  case "$1" in
    --uninstall)
      install=false
      shift
      ;;
    *)
      echo "使い方: $0 [--uninstall]"
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
  "config/git/.gitattributes:$HOME/.gitattributes"
  "config/tmux/.tmux.conf:$HOME/.tmux.conf"
  "config/vim/.vimrc:$HOME/.vimrc"
  "config/shell/zsh/mytheme.zsh-theme:$HOME/.oh-my-zsh/themes/mytheme.zsh-theme"
  "config/termux/termux.properties:$HOME/.termux/termux.properties"
  "config/claude/CLAUDE.md:$HOME/.claude/CLAUDE.md"
  "config/claude/settings.json:$HOME/.claude/settings.json"
  "config/claude/agents/code-reviewer.md:$HOME/.claude/agents/code-reviewer.md"
  "config/vscode/settings.json:$HOME/.config/Code/User/settings.json"
  "config/editorconfig/.editorconfig:$HOME/.editorconfig"
  "config/opencode/opencode.jsonc:$HOME/.config/opencode/opencode.jsonc"
  "config/opencode/tui.json:$HOME/.config/opencode/tui.json"
  "config/deepagents/config.toml:$HOME/.deepagents/config.toml"
  "config/deepagents/.mcp.json:$HOME/.deepagents/.mcp.json"
)

# ---

skipped=0
linked=0
restored=0

process_dir() {
  local source_dir_path="$1"
  local target_dir_path="$2"

  if [ "$install" = true ]; then
    if [ -L "$target_dir_path" ]; then
      echo "  ⏭️  スキップ       $target_dir_path"
      echo "              シンボリックリンクが既に存在します"
      (( skipped++ )) || true
      return
    fi
    if [ -d "$target_dir_path" ] && [ ! -L "$target_dir_path" ]; then
      echo "  📦 バックアップ   $target_dir_path"
      echo "              → ${target_dir_path}.pre-dotfiles"
      mv "$target_dir_path" "$target_dir_path.pre-dotfiles"
    fi
    ln -s "$source_dir_path" "$target_dir_path"
    echo "  🔗 リンク作成     $target_dir_path"
    echo "              → $source_dir_path"
    (( linked++ )) || true
  else
    if [ -L "$target_dir_path" ]; then
      rm "$target_dir_path"
      echo "  🗑️  リンク削除     $target_dir_path"
    fi
    if [ -d "$target_dir_path.pre-dotfiles" ]; then
      mv "$target_dir_path.pre-dotfiles" "$target_dir_path"
      echo "  ♻️  リストア       ${target_dir_path}.pre-dotfiles"
      echo "              → $target_dir_path"
      (( restored++ )) || true
    fi
  fi
}

process_file() {
  local source_file="$1"
  local target_file="$2"
  local target_dir
  target_dir="$(dirname "$target_file")"

  if [ "$install" = true ]; then

    if [ ! -d "$target_dir" ]; then
      echo "  ⏭️  スキップ       $target_file"
      echo "              ディレクトリが存在しません: $target_dir"
      (( skipped++ )) || true
      return
    fi

    if [ -L "$target_file" ]; then
      echo "  ⏭️  スキップ       $target_file"
      echo "              シンボリックリンクが既に存在します"
      (( skipped++ )) || true
      return
    fi

    if [ -f "$target_file" ]; then
      echo "  📦 バックアップ   $target_file"
      echo "              → ${target_file}.pre-dotfiles"
      mv "$target_file" "$target_file.pre-dotfiles"
    fi

    ln -s "$source_file" "$target_file"
    echo "  🔗 リンク作成     $target_file"
    echo "              → $source_file"
    (( linked++ )) || true

  else

    if [ -L "$target_file" ]; then
      rm "$target_file"
      echo "  🗑️  リンク削除     $target_file"
    fi

    if [ -f "$target_file.pre-dotfiles" ]; then
      mv "$target_file.pre-dotfiles" "$target_file"
      echo "  ♻️  リストア       ${target_file}.pre-dotfiles"
      echo "              → $target_file"
      (( restored++ )) || true
    fi

  fi
}

# ヘッダー
echo ""
if [ "$install" = true ]; then
  echo "🏠 dotfiles インストール"
else
  echo "🗑️  dotfiles アンインストール"
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# シンボリックリンク先が存在しないディレクトリを事前に作成
if [ "$install" = true ]; then
  [ -d "$HOME/.claude" ] && mkdir -p "$HOME/.claude/agents"
  mkdir -p "$HOME/.config/opencode"
  mkdir -p "$HOME/.deepagents"
  mkdir -p "$HOME/.ssh/control"
  chmod 700 "$HOME/.ssh" "$HOME/.ssh/control"
fi

for entry in "${files[@]}"; do
  src_rel="${entry%%:*}"
  target_file="${entry##*:}"
  process_file "$source_dir/$src_rel" "$target_file"
done

# ディレクトリ単位でシンボリックリンクするエントリ
dirs=(
  "config/deepagents/agents:$HOME/.deepagents/agents"
  "config/claude/skills:$HOME/.claude/skills"
)

for entry in "${dirs[@]}"; do
  src_rel="${entry%%:*}"
  target_dir_path="${entry##*:}"
  process_dir "$source_dir/$src_rel" "$target_dir_path"
done

# フッター
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ "$install" = true ]; then
  echo "✅ 完了  リンク: ${linked}  スキップ: ${skipped}"
else
  echo "✅ 完了  リストア: ${restored}"
fi
echo ""
