#!/bin/bash
# 新環境セットアップスクリプト
# 依存パッケージ確認・インストール、oh-my-zsh セットアップ、dotfiles インストールまでを実行する
set -u

repo_dir="$(cd "$(dirname "$0")" && pwd)"

# --- パッケージマネージャー検出 ---
if command -v apt-get &>/dev/null; then
  pkg_install() { sudo apt-get install -y "$@"; }
  pkg_check()   { dpkg -s "$1" &>/dev/null; }
elif command -v pkg &>/dev/null; then
  # Termux
  pkg_install() { pkg install -y "$@"; }
  pkg_check()   { pkg list-installed 2>/dev/null | grep -q "^$1/"; }
else
  echo "❌ サポートされていないパッケージマネージャーです (apt / pkg のみ対応)"
  exit 1
fi

echo ""
echo "🚀 dotfiles bootstrap"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# --- 依存パッケージ確認・インストール ---
echo "📦 依存パッケージを確認中..."
packages=(git jq curl vim tmux zsh)
# dislocker は Termux 非対象
command -v pkg &>/dev/null || packages+=(dislocker)

missing=()
for p in "${packages[@]}"; do
  if ! pkg_check "$p" && ! command -v "$p" &>/dev/null; then
    missing+=("$p")
  fi
done

if [ "${#missing[@]}" -gt 0 ]; then
  echo "  インストールが必要: ${missing[*]}"
  pkg_install "${missing[@]}"
  echo "  ✅ インストール完了"
else
  echo "  ✅ すべての依存パッケージが揃っています"
fi
echo ""

# --- oh-my-zsh ---
echo "🐚 oh-my-zsh を確認中..."
if [ -d "$HOME/.oh-my-zsh" ]; then
  echo "  ✅ oh-my-zsh はインストール済みです"
else
  echo "  インストールします..."
  RUNZSH=no CHSH=no sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  echo "  ✅ oh-my-zsh をインストールしました"
fi
echo ""

# --- .env テンプレート配置案内 ---
echo "🔑 シークレット設定ファイルを確認中..."
templates=(
  "config/shell/bin/ntfy-claude.env.example:$HOME/.config/ntfy-claude.env"
  "config/claude/.env.example:$HOME/.env"
  "config/deepagents/.env.example:$HOME/.deepagents/.env"
  "config/hermes/.env.example:$HOME/.hermes/.env"
  "config/opencode/.env.example:$HOME/.config/opencode/.env"
  "config/codex/.env.example:$HOME/.codex/.env"
)

needs_setup=false
for entry in "${templates[@]}"; do
  src_rel="${entry%%:*}"
  dest="${entry##*:}"
  src="$repo_dir/$src_rel"
  [ -f "$src" ] || continue
  if [ ! -f "$dest" ]; then
    echo "  ⚠️  未作成: $dest"
    echo "       テンプレート: $src_rel"
    needs_setup=true
  fi
done

if [ "$needs_setup" = false ]; then
  echo "  ✅ すべての設定ファイルが存在します"
else
  echo ""
  echo "  上記ファイルをテンプレートからコピーして設定してください:"
  echo "    cp <テンプレート> <配置先>  # 配置先を編集してトークン等を設定"
fi
echo ""

# --- dotfiles インストール ---
echo "🏠 dotfiles をインストール中..."
"$repo_dir/install.sh"
