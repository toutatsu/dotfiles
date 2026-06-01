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
  "config/vscode/settings.json:$HOME/.config/Code/User/settings.json"
  "config/editorconfig/.editorconfig:$HOME/.editorconfig"
  "config/opencode/opencode.jsonc:$HOME/.config/opencode/opencode.jsonc"
  "config/opencode/tui.json:$HOME/.config/opencode/tui.json"
  "config/opencode/AGENTS.md:$HOME/.config/opencode/AGENTS.md"
  "config/deepagents/config.toml:$HOME/.deepagents/config.toml"
  "config/deepagents/.mcp.json:$HOME/.deepagents/.mcp.json"
  # "config/deepagents/AGENTS.md:$HOME/.deepagents/agent/AGENTS.md"  # エラーが発生するため無効化
  "config/codex/config.toml:$HOME/.codex/config.toml"
  "config/codex/AGENTS.md:$HOME/.codex/AGENTS.md"
  "config/hermes/config.yaml:$HOME/.hermes/config.yaml"
  "config/hermes/AGENTS.md:$HOME/.hermes/AGENTS.md"
  "config/hermes/SOUL.md:$HOME/.hermes/SOUL.md"
)

# ---

skipped=0
linked=0
failed=0
restored=0
removed=0

process_dir() {
  local source_dir_path="$1"
  local target_dir_path="$2"

  if [ "$install" = true ]; then
    if [ ! -d "$source_dir_path" ]; then
      echo "  ⏭️  スキップ       $target_dir_path"
      echo "              ソースディレクトリが存在しません: $source_dir_path"
      (( skipped++ )) || true
      return
    fi
    if [ -L "$target_dir_path" ]; then
      echo "  ⏭️  スキップ       $target_dir_path"
      echo "              シンボリックリンクが既に存在します"
      (( skipped++ )) || true
      return
    fi
    if [ -d "$target_dir_path" ] && [ ! -L "$target_dir_path" ]; then
      echo "  📦 バックアップ   $target_dir_path"
      echo "              → ${target_dir_path}.pre-dotfiles"
      if ! mv "$target_dir_path" "$target_dir_path.pre-dotfiles"; then
        echo "  ❌ 失敗           バックアップに失敗しました: $target_dir_path"
        (( failed++ )) || true
        return
      fi
    fi
    if ln -s "$source_dir_path" "$target_dir_path"; then
      echo "  🔗 リンク作成     $target_dir_path"
      echo "              → $source_dir_path"
      (( linked++ )) || true
    else
      echo "  ❌ 失敗           $target_dir_path"
      (( failed++ )) || true
    fi
  else
    if [ -L "$target_dir_path" ]; then
      rm "$target_dir_path"
      echo "  🗑️  リンク削除     $target_dir_path"
      (( removed++ )) || true
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
      if ! mv "$target_file" "$target_file.pre-dotfiles"; then
        echo "  ❌ 失敗           バックアップに失敗しました: $target_file"
        (( failed++ )) || true
        return
      fi
    fi

    if ln -s "$source_file" "$target_file"; then
      echo "  🔗 リンク作成     $target_file"
      echo "              → $source_file"
      (( linked++ )) || true
    else
      echo "  ❌ 失敗           $target_file"
      (( failed++ )) || true
    fi

  else

    if [ -L "$target_file" ]; then
      rm "$target_file"
      echo "  🗑️  リンク削除     $target_file"
      (( removed++ )) || true
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
  mkdir -p "$HOME/.config/opencode"
  mkdir -p "$HOME/.deepagents/agent"
  mkdir -p "$HOME/.codex"
  mkdir -p "$HOME/.hermes"
  mkdir -p "$HOME/.ssh/control"
  mkdir -p "$HOME/.local/bin"
  mkdir -p "$HOME/.local/share/dotfiles/functions"
  chmod 700 "$HOME/.ssh" "$HOME/.ssh/control"
fi

for entry in "${files[@]}"; do
  src_rel="${entry%%:*}"
  target_file="${entry##*:}"
  process_file "$source_dir/$src_rel" "$target_file"
done

# ディレクトリ単位でシンボリックリンクするエントリ
dirs=(
  "config/deepagents/agents:$HOME/.deepagents/agent/agents"
  "config/deepagents/skills:$HOME/.deepagents/agent/skills"
  "config/claude/agents:$HOME/.claude/agents"
  "config/claude/skills:$HOME/.claude/skills"
  "config/opencode/agents:$HOME/.config/opencode/agents"
  "config/opencode/skills:$HOME/.config/opencode/skills"
  "config/opencode/tools:$HOME/.config/opencode/tools"
  "config/codex/skills:$HOME/.codex/skills"
)

for entry in "${dirs[@]}"; do
  src_rel="${entry%%:*}"
  target_dir_path="${entry##*:}"
  process_dir "$source_dir/$src_rel" "$target_dir_path"
done

# ファイル単位でシンボリックリンクするディレクトリ（既存ファイルを上書きしない）
file_spread_dirs=(
  "config/shell/bin:$HOME/.local/bin"
  "config/shell/functions:$HOME/.local/share/dotfiles/functions"
)

for entry in "${file_spread_dirs[@]}"; do
  src_rel="${entry%%:*}"
  target_dir="${entry##*:}"
  for src_file in "$source_dir/$src_rel/"*; do
    [ -f "$src_file" ] || continue
    [[ "$src_file" == *.example ]] && continue
    process_file "$src_file" "$target_dir/$(basename "$src_file")"
  done
done

# フッター
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ "$install" = true ]; then
  if [ "$failed" -gt 0 ]; then
    echo "⚠️  完了  リンク: ${linked}  スキップ: ${skipped}  失敗: ${failed}"
  else
    echo "✅ 完了  リンク: ${linked}  スキップ: ${skipped}"
  fi
else
  echo "✅ 完了  削除: ${removed}  リストア: ${restored}"
fi
echo ""
