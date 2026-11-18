#!/bin/bash
set -u

mode="install"
dry_run=false
force=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --uninstall)
      mode="uninstall"
      shift
      ;;
    --dry-run)
      dry_run=true
      shift
      ;;
    --force)
      force=true
      shift
      ;;
    status)
      mode="status"
      shift
      ;;
    *)
      echo "使い方: $0 [--uninstall|status] [--dry-run] [--force]"
      exit 1
      ;;
  esac
done

# リポジトリのルートディレクトリ（どこから実行しても正しく解決される）
repo_dir="$(cd "$(dirname "$0")" && pwd)"

# "リポジトリ内の相対パス:配置先の絶対パス" 形式
file_links=(
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
  # Remote/Tunnel 接続される側で有効になる Machine スコープ設定（WSL・SSH Remote・code tunnel 等。親ディレクトリが無い環境では自動スキップ）
  "config/vscode/settings.json:$HOME/.vscode-server/data/Machine/settings.json"
  "config/editorconfig/.editorconfig:$HOME/.editorconfig"
  "config/opencode/opencode.jsonc:$HOME/.config/opencode/opencode.jsonc"
  "config/opencode/tui.json:$HOME/.config/opencode/tui.json"
  "config/opencode/AGENTS.md:$HOME/.config/opencode/AGENTS.md"
  "config/deepagents/config.toml:$HOME/.deepagents/config.toml"
  "config/deepagents/.mcp.json:$HOME/.deepagents/.mcp.json"
  "config/deepagents/AGENTS.md:$HOME/.deepagents/agent/AGENTS.md"
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
st_ok=0
st_missing=0
st_warn=0
st_dead=0

status_entry() {
  local source_path="$1"
  local target_path="$2"

  if [ -L "$target_path" ]; then
    local dest
    dest="$(readlink "$target_path")"
    if [ "$dest" = "$source_path" ]; then
      if [ -e "$target_path" ]; then
        echo "  ✅ リンク済み     $target_path"
        (( st_ok++ )) || true
      else
        echo "  💀 リンク切れ     $target_path"
        echo "              → $dest"
        (( st_dead++ )) || true
      fi
    else
      echo "  ⚠️  別リンク        $target_path"
      echo "              → $dest"
      (( st_warn++ )) || true
    fi
  elif [ -e "$target_path" ]; then
    echo "  ⚠️  実体ファイル    $target_path"
    (( st_warn++ )) || true
  else
    echo "  ❌ 未リンク       $target_path"
    (( st_missing++ )) || true
  fi
}

process_dir() {
  local source_dir_path="$1"
  local target_dir_path="$2"

  if [ "$mode" = "install" ]; then
    if [ ! -d "$source_dir_path" ]; then
      echo "  ⏭️  スキップ       $target_dir_path"
      echo "              ソースディレクトリが存在しません: $source_dir_path"
      (( skipped++ )) || true
      return
    fi
    if [ -L "$target_dir_path" ]; then
      if [ "$(readlink "$target_dir_path")" = "$source_dir_path" ]; then
        echo "  ⏭️  スキップ       $target_dir_path"
        echo "              シンボリックリンクが既に存在します"
        (( skipped++ )) || true
        return
      elif [ "$force" = false ]; then
        echo "  ⚠️  スキップ       $target_dir_path"
        echo "              別の場所を指すリンクが存在します: $(readlink "$target_dir_path")"
        echo "              上書きするには --force を指定してください"
        (( skipped++ )) || true
        return
      else
        echo "  📦 バックアップ   $target_dir_path"
        echo "              → ${target_dir_path}.pre-dotfiles"
        if [ "$dry_run" = false ]; then
          if ! mv "$target_dir_path" "$target_dir_path.pre-dotfiles"; then
            echo "  ❌ 失敗           バックアップに失敗しました: $target_dir_path"
            (( failed++ )) || true
            return
          fi
        fi
      fi
    fi
    if [ -d "$target_dir_path" ] && [ ! -L "$target_dir_path" ]; then
      echo "  📦 バックアップ   $target_dir_path"
      echo "              → ${target_dir_path}.pre-dotfiles"
      if [ "$dry_run" = false ]; then
        if ! mv "$target_dir_path" "$target_dir_path.pre-dotfiles"; then
          echo "  ❌ 失敗           バックアップに失敗しました: $target_dir_path"
          (( failed++ )) || true
          return
        fi
      fi
    fi
    echo "  🔗 リンク作成     $target_dir_path"
    echo "              → $source_dir_path"
    if [ "$dry_run" = false ]; then
      if ln -s "$source_dir_path" "$target_dir_path"; then
        (( linked++ )) || true
      else
        echo "  ❌ 失敗           $target_dir_path"
        (( failed++ )) || true
      fi
    else
      (( linked++ )) || true
    fi
  else
    if [ -L "$target_dir_path" ]; then
      if [ "$(readlink "$target_dir_path")" = "$source_dir_path" ]; then
        if [ "$dry_run" = false ]; then
          rm "$target_dir_path"
        fi
        echo "  🗑️  リンク削除     $target_dir_path"
        (( removed++ )) || true
      else
        echo "  ⏭️  スキップ       $target_dir_path"
        echo "              このリポジトリ外を指すリンクのため削除しません"
        (( skipped++ )) || true
        return
      fi
    fi
    if [ -d "$target_dir_path.pre-dotfiles" ]; then
      echo "  ♻️  リストア       ${target_dir_path}.pre-dotfiles"
      echo "              → $target_dir_path"
      if [ "$dry_run" = false ]; then
        mv "$target_dir_path.pre-dotfiles" "$target_dir_path"
      fi
      (( restored++ )) || true
    fi
  fi
}

process_file() {
  local source_file="$1"
  local target_file="$2"
  local target_dir
  target_dir="$(dirname "$target_file")"

  if [ "$mode" = "install" ]; then

    if [ ! -d "$target_dir" ] && [ "$dry_run" = false ]; then
      echo "  ⏭️  スキップ       $target_file"
      echo "              ディレクトリが存在しません: $target_dir"
      (( skipped++ )) || true
      return
    fi

    if [ -L "$target_file" ]; then
      if [ "$(readlink "$target_file")" = "$source_file" ]; then
        echo "  ⏭️  スキップ       $target_file"
        echo "              シンボリックリンクが既に存在します"
        (( skipped++ )) || true
        return
      elif [ "$force" = false ]; then
        echo "  ⚠️  スキップ       $target_file"
        echo "              別の場所を指すリンクが存在します: $(readlink "$target_file")"
        echo "              上書きするには --force を指定してください"
        (( skipped++ )) || true
        return
      else
        echo "  📦 バックアップ   $target_file"
        echo "              → ${target_file}.pre-dotfiles"
        if [ "$dry_run" = false ]; then
          if ! mv "$target_file" "$target_file.pre-dotfiles"; then
            echo "  ❌ 失敗           バックアップに失敗しました: $target_file"
            (( failed++ )) || true
            return
          fi
        fi
      fi
    fi

    if [ -f "$target_file" ]; then
      echo "  📦 バックアップ   $target_file"
      echo "              → ${target_file}.pre-dotfiles"
      if [ "$dry_run" = false ]; then
        if ! mv "$target_file" "$target_file.pre-dotfiles"; then
          echo "  ❌ 失敗           バックアップに失敗しました: $target_file"
          (( failed++ )) || true
          return
        fi
      fi
    fi

    echo "  🔗 リンク作成     $target_file"
    echo "              → $source_file"
    if [ "$dry_run" = false ]; then
      if ln -s "$source_file" "$target_file"; then
        (( linked++ )) || true
      else
        echo "  ❌ 失敗           $target_file"
        (( failed++ )) || true
      fi
    else
      (( linked++ )) || true
    fi

  else

    if [ -L "$target_file" ]; then
      if [ "$(readlink "$target_file")" = "$source_file" ]; then
        if [ "$dry_run" = false ]; then
          rm "$target_file"
        fi
        echo "  🗑️  リンク削除     $target_file"
        (( removed++ )) || true
      else
        echo "  ⏭️  スキップ       $target_file"
        echo "              このリポジトリ外を指すリンクのため削除しません"
        (( skipped++ )) || true
        return
      fi
    fi

    if [ -f "$target_file.pre-dotfiles" ]; then
      echo "  ♻️  リストア       ${target_file}.pre-dotfiles"
      echo "              → $target_file"
      if [ "$dry_run" = false ]; then
        mv "$target_file.pre-dotfiles" "$target_file"
      fi
      (( restored++ )) || true
    fi

  fi
}

# ヘッダー
echo ""
force_label=""
[ "$force" = true ] && force_label=" [FORCE]"
if [ "$mode" = "install" ]; then
  if [ "$dry_run" = true ]; then
    echo "🏠 dotfiles インストール [DRY RUN]${force_label}"
  else
    echo "🏠 dotfiles インストール${force_label}"
  fi
elif [ "$mode" = "status" ]; then
  echo "🔍 dotfiles ステータス"
else
  if [ "$dry_run" = true ]; then
    echo "🗑️  dotfiles アンインストール [DRY RUN]"
  else
    echo "🗑️  dotfiles アンインストール"
  fi
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# シンボリックリンク先が存在しないディレクトリを事前に作成
if [ "$mode" = "install" ] && [ "$dry_run" = false ]; then
  mkdir -p "$HOME/.claude"
  mkdir -p "$HOME/.config/opencode"
  mkdir -p "$HOME/.deepagents/agent"
  mkdir -p "$HOME/.codex"
  mkdir -p "$HOME/.hermes"
  mkdir -p "$HOME/.ssh/control"
  mkdir -p "$HOME/.local/bin"
  mkdir -p "$HOME/.local/share/dotfiles/functions"
  chmod 700 "$HOME/.ssh" "$HOME/.ssh/control"
fi

for entry in "${file_links[@]}"; do
  src_rel="${entry%%:*}"
  target_file="${entry##*:}"
  if [ "$mode" = "status" ]; then
    status_entry "$repo_dir/$src_rel" "$target_file"
  else
    process_file "$repo_dir/$src_rel" "$target_file"
  fi
done

# ディレクトリ単位でシンボリックリンクするエントリ
dir_links=(
  "config/deepagents/agents:$HOME/.deepagents/agent/agents"
  "config/deepagents/skills:$HOME/.deepagents/agent/skills"
  "config/claude/agents:$HOME/.claude/agents"
  "config/claude/skills:$HOME/.claude/skills"
  "config/opencode/agents:$HOME/.config/opencode/agents"
  "config/opencode/skills:$HOME/.config/opencode/skills"
  "config/opencode/tools:$HOME/.config/opencode/tools"
  "config/codex/skills:$HOME/.codex/skills"
)

for entry in "${dir_links[@]}"; do
  src_rel="${entry%%:*}"
  target_dir_path="${entry##*:}"
  if [ "$mode" = "status" ]; then
    status_entry "$repo_dir/$src_rel" "$target_dir_path"
  else
    process_dir "$repo_dir/$src_rel" "$target_dir_path"
  fi
done

# ファイル単位でシンボリックリンクするディレクトリ（既存ファイルを上書きしない）
spread_dirs=(
  "config/shell/bin:$HOME/.local/bin"
  "config/shell/functions:$HOME/.local/share/dotfiles/functions"
)

for entry in "${spread_dirs[@]}"; do
  src_rel="${entry%%:*}"
  spread_target_dir="${entry##*:}"
  for src_file in "$repo_dir/$src_rel/"*; do
    [ -f "$src_file" ] || continue
    [[ "$src_file" == *.example ]] && continue
    if [ "$mode" = "status" ]; then
      status_entry "$src_file" "$spread_target_dir/$(basename "$src_file")"
    else
      process_file "$src_file" "$spread_target_dir/$(basename "$src_file")"
    fi
  done
done

# フッター
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
dry_run_label=""
[ "$dry_run" = true ] && dry_run_label=" [DRY RUN]"
if [ "$mode" = "status" ]; then
  total=$(( st_ok + st_missing + st_warn + st_dead ))
  if [ "$st_missing" -gt 0 ] || [ "$st_warn" -gt 0 ] || [ "$st_dead" -gt 0 ]; then
    echo "⚠️  合計: ${total}  ✅ リンク済み: ${st_ok}  ❌ 未リンク: ${st_missing}  ⚠️  警告: ${st_warn}  💀 切れ: ${st_dead}"
  else
    echo "✅ 合計: ${total}  すべてリンク済み"
  fi
elif [ "$mode" = "install" ]; then
  if [ "$failed" -gt 0 ]; then
    echo "⚠️  完了${dry_run_label}  リンク: ${linked}  スキップ: ${skipped}  失敗: ${failed}"
  else
    echo "✅ 完了${dry_run_label}  リンク: ${linked}  スキップ: ${skipped}"
  fi
else
  echo "✅ 完了${dry_run_label}  削除: ${removed}  リストア: ${restored}  スキップ: ${skipped}"
fi
echo ""
